const verificationService = require('../services/verificationService');
const Verification = require('../models/Verification');
const AppError = require('../utils/AppError');
const logger = require('../utils/logger');
const path = require('path');
const fs = require('fs').promises;

/**
 * Verify uploaded evidence file
 */
exports.verifyEvidence = async (req, res, next) => {
  try {
    // Check if file was uploaded
    if (!req.file) {
      return next(new AppError('No file uploaded for verification', 400));
    }

    const filePath = req.file.path;
    const fileType = req.file.mimetype;

    logger.info(`Starting verification for file: ${req.file.originalname}`);

    // Analyze the file
    const analysisResults = await verificationService.analyzeFile(filePath, fileType);

    // Generate comprehensive report
    const verificationReport = verificationService.generateReport(analysisResults);

    // Save verification to database
    const verificationData = {
      verificationId: verificationReport.verificationId,
      userId: req.user?._id,
      reportId: req.body.reportId || null,
      fileHash: analysisResults.fileHash,
      fileName: req.file.originalname,
      fileSize: analysisResults.fileSize,
      fileType: analysisResults.fileType,
      mediaType: analysisResults.mediaType,
      results: {
        authenticityLevel: analysisResults.authenticityLevel,
        authenticityDescription: analysisResults.authenticityDescription,
        metadataVerified: analysisResults.metadataVerified,
        editHistory: analysisResults.editHistory,
        signatureValid: analysisResults.signatureValid,
        manipulationScore: analysisResults.manipulationScore,
        metadata: analysisResults.metadata,
      },
      summary: verificationReport.summary,
      status: 'completed',
      isAnonymous: !req.user,
    };

    const savedVerification = await Verification.create(verificationData);

    // Clean up uploaded file after analysis
    try {
      await fs.unlink(filePath);
    } catch (unlinkError) {
      logger.error('Failed to delete temporary file:', unlinkError);
    }

    logger.info(`Verification completed: ${verificationReport.verificationId}`);

    res.status(200).json({
      status: 'success',
      data: {
        verification: verificationReport,
        saved: true,
      },
    });
  } catch (error) {
    logger.error('Verification error:', error);
    
    // Clean up file on error
    if (req.file?.path) {
      try {
        await fs.unlink(req.file.path);
      } catch (unlinkError) {
        logger.error('Failed to delete file after error:', unlinkError);
      }
    }

    next(new AppError('Failed to verify evidence: ' + error.message, 500));
  }
};

/**
 * Get verification history for a user
 */
exports.getVerificationHistory = async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 20;
    const page = parseInt(req.query.page) || 1;
    const skip = (page - 1) * limit;

    const query = req.user ? { userId: req.user._id } : {};

    const [verifications, total] = await Promise.all([
      Verification.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .select('-results.metadata')
        .populate('reportId', 'reportId title status'),
      Verification.countDocuments(query),
    ]);

    res.status(200).json({
      status: 'success',
      data: {
        verifications,
        pagination: {
          total,
          page,
          pages: Math.ceil(total / limit),
          limit,
        },
      },
    });
  } catch (error) {
    logger.error('Get verification history error:', error);
    next(new AppError('Failed to retrieve verification history', 500));
  }
};

/**
 * Compare file hash with database
 */
exports.compareEvidence = async (req, res, next) => {
  try {
    const { fileHash } = req.body;

    if (!fileHash) {
      return next(new AppError('File hash is required', 400));
    }

    const comparisonResults = await verificationService.compareWithDatabase(fileHash);

    res.status(200).json({
      status: 'success',
      data: comparisonResults,
    });
  } catch (error) {
    logger.error('Evidence comparison error:', error);
    next(new AppError('Failed to compare evidence', 500));
  }
};

/**
 * Batch verify multiple files
 */
exports.batchVerify = async (req, res, next) => {
  try {
    if (!req.files || req.files.length === 0) {
      return next(new AppError('No files uploaded for verification', 400));
    }

    const verificationPromises = req.files.map(async (file) => {
      try {
        const analysisResults = await verificationService.analyzeFile(
          file.path,
          file.mimetype
        );
        const report = verificationService.generateReport(analysisResults);

        // Clean up file
        await fs.unlink(file.path);

        return {
          filename: file.originalname,
          status: 'success',
          verification: report,
        };
      } catch (error) {
        logger.error(`Failed to verify ${file.originalname}:`, error);
        
        // Clean up file on error
        try {
          await fs.unlink(file.path);
        } catch (unlinkError) {
          logger.error('Failed to delete file:', unlinkError);
        }

        return {
          filename: file.originalname,
          status: 'failed',
          error: error.message,
        };
      }
    });

    const results = await Promise.all(verificationPromises);

    res.status(200).json({
      status: 'success',
      data: {
        results,
        summary: {
          total: results.length,
          successful: results.filter((r) => r.status === 'success').length,
          failed: results.filter((r) => r.status === 'failed').length,
        },
      },
    });
  } catch (error) {
    logger.error('Batch verification error:', error);
    next(new AppError('Failed to process batch verification', 500));
  }
};
