const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const path = require('path');
const Report = require('../models/Report');
const AppError = require('../utils/AppError');
const config = require('../config/config');
const { getFirebaseStorage } = require('../config/firebase');
const { encryptFile, generateFileHash } = require('../utils/encryption');
const { addWatermark, generateMetadataWatermark, stripExifData, resizeImage } = require('../utils/watermark');
const logger = require('../utils/logger');

// Multer configuration for memory storage
const storage = multer.memoryStorage();

// File filter
const fileFilter = (req, file, cb) => {
  const allowedMimeTypes = [
    'image/png',
    'image/jpeg',
    'image/jpg',
    'application/pdf',
    'text/plain',
    'text/log',
    'application/octet-stream', // For .log files
  ];

  const allowedExtensions = ['.png', '.jpg', '.jpeg', '.pdf', '.txt', '.log'];
  const ext = path.extname(file.originalname).toLowerCase();

  if (allowedMimeTypes.includes(file.mimetype) || allowedExtensions.includes(ext)) {
    cb(null, true);
  } else {
    cb(new AppError(`File type not allowed. Allowed types: PNG, JPG, PDF, TXT, LOG`, 400), false);
  }
};

// Multer upload configuration
const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: config.upload.maxFileSize, // 10MB
    files: 5, // Max 5 files per upload
  },
});

/**
 * Simulate malware scan (in production, use a real AV service)
 * @param {Buffer} buffer - File buffer
 * @returns {Promise<Object>} - Scan result
 */
const scanForMalware = async (buffer) => {
  // In production, integrate with ClamAV or cloud-based AV service
  // For now, simulate a scan
  try {
    // Check for common malware signatures (simplified)
    const bufferString = buffer.toString('hex').toLowerCase();
    
    // Known malware signatures (very basic example)
    const malwareSignatures = [
      '4d5a9000', // PE executable
      '504b0304', // ZIP file (could contain malware)
    ];

    // For this demo, we'll allow ZIP files but flag executables
    const hasExecutable = bufferString.startsWith('4d5a');
    
    if (hasExecutable) {
      return {
        isSafe: false,
        scanResult: 'Executable files are not allowed',
      };
    }

    return {
      isSafe: true,
      scanResult: 'No threats detected',
    };
  } catch (error) {
    logger.error('Malware scan error:', error);
    return {
      isSafe: null,
      scanResult: 'Scan failed',
    };
  }
};

/**
 * Process and upload file to Firebase Storage
 * @param {Object} file - Multer file object
 * @param {string} reportId - Report ID
 * @param {string} userId - User ID
 * @returns {Promise<Object>} - Upload result
 */
const processAndUploadFile = async (file, reportId, userId) => {
  try {
    let processedBuffer = file.buffer;
    const fileId = uuidv4();
    const ext = path.extname(file.originalname).toLowerCase();
    
    // 1. Scan for malware
    const malwareScan = await scanForMalware(processedBuffer);
    if (malwareScan.isSafe === false) {
      throw new AppError(`File rejected: ${malwareScan.scanResult}`, 400);
    }

    // 2. Process images
    if (['.png', '.jpg', '.jpeg'].includes(ext)) {
      // Strip EXIF data for privacy
      processedBuffer = await stripExifData(processedBuffer);
      
      // Resize if too large
      processedBuffer = await resizeImage(processedBuffer, {
        maxWidth: 2048,
        maxHeight: 2048,
        quality: 85,
      });
      
      // Add watermark
      const watermarkText = `ReportCyber-${reportId}`;
      processedBuffer = await addWatermark(processedBuffer, watermarkText);
    }

    // 3. Generate file hash for integrity
    const fileHash = generateFileHash(processedBuffer);

    // 4. Encrypt file
    const { encryptedBuffer, iv } = encryptFile(processedBuffer);

    // 5. Generate watermark metadata
    const watermarkMetadata = generateMetadataWatermark({
      userId,
      reportId,
      originalName: file.originalname,
      uploadTime: new Date().toISOString(),
    });

    // 6. Upload to Firebase Storage
    const bucket = getFirebaseStorage();
    const fileName = `reports/${reportId}/${fileId}${ext}`;
    const fileRef = bucket.file(fileName);

    await fileRef.save(encryptedBuffer, {
      metadata: {
        contentType: file.mimetype,
        metadata: {
          originalName: file.originalname,
          fileHash,
          encryptionIv: iv,
          watermark: JSON.stringify(watermarkMetadata),
          uploadedBy: userId || 'anonymous',
          reportId,
        },
      },
    });

    // Generate signed URL (valid for 7 days)
    const [signedUrl] = await fileRef.getSignedUrl({
      action: 'read',
      expires: Date.now() + 7 * 24 * 60 * 60 * 1000,
    });

    return {
      fileId,
      originalName: file.originalname,
      mimeType: file.mimetype,
      size: file.size,
      storageUrl: signedUrl,
      encryptionIv: iv,
      fileHash,
      watermark: watermarkMetadata,
      malwareScan: {
        scanned: true,
        isSafe: malwareScan.isSafe,
        scanResult: malwareScan.scanResult,
        scannedAt: new Date(),
      },
    };
  } catch (error) {
    logger.error('File processing error:', error);
    throw error;
  }
};

/**
 * Upload files for a report
 * POST /api/v1/reports/:id/attachments
 */
const uploadAttachments = async (req, res, next) => {
  try {
    const { id } = req.params;
    const report = await Report.findById(id);

    if (!report) {
      return next(new AppError('Report not found', 404));
    }

    // Check ownership
    if (report.reporter && report.reporter.toString() !== req.user?._id.toString()) {
      if (!['admin', 'moderator'].includes(req.user?.role)) {
        return next(new AppError('You do not have permission to add attachments', 403));
      }
    }

    if (!req.files || req.files.length === 0) {
      return next(new AppError('No files uploaded', 400));
    }

    // Check total attachments limit
    if (report.attachments.length + req.files.length > 10) {
      return next(new AppError('Maximum 10 attachments allowed per report', 400));
    }

    // Process and upload each file
    const uploadResults = await Promise.all(
      req.files.map((file) =>
        processAndUploadFile(file, report.reportId, req.user?._id?.toString())
      )
    );

    // Add to report
    report.attachments.push(...uploadResults);
    await report.save();

    res.status(200).json({
      success: true,
      message: `${uploadResults.length} file(s) uploaded successfully`,
      data: {
        attachments: uploadResults.map((a) => ({
          fileId: a.fileId,
          originalName: a.originalName,
          mimeType: a.mimeType,
          size: a.size,
        })),
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete attachment
 * DELETE /api/v1/reports/:id/attachments/:fileId
 */
const deleteAttachment = async (req, res, next) => {
  try {
    const { id, fileId } = req.params;
    const report = await Report.findById(id);

    if (!report) {
      return next(new AppError('Report not found', 404));
    }

    // Check ownership
    if (report.reporter && report.reporter.toString() !== req.user?._id.toString()) {
      if (!['admin', 'moderator'].includes(req.user?.role)) {
        return next(new AppError('You do not have permission to delete attachments', 403));
      }
    }

    // Find and remove attachment
    const attachmentIndex = report.attachments.findIndex((a) => a.fileId === fileId);
    if (attachmentIndex === -1) {
      return next(new AppError('Attachment not found', 404));
    }

    // Delete from Firebase Storage
    try {
      const bucket = getFirebaseStorage();
      const ext = path.extname(report.attachments[attachmentIndex].originalName);
      const fileName = `reports/${report.reportId}/${fileId}${ext}`;
      await bucket.file(fileName).delete();
    } catch (storageError) {
      logger.error('Failed to delete file from storage:', storageError);
    }

    report.attachments.splice(attachmentIndex, 1);
    await report.save();

    res.status(200).json({
      success: true,
      message: 'Attachment deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get attachment download URL
 * GET /api/v1/reports/:id/attachments/:fileId
 */
const getAttachment = async (req, res, next) => {
  try {
    const { id, fileId } = req.params;
    const report = await Report.findById(id);

    if (!report) {
      return next(new AppError('Report not found', 404));
    }

    // Check access permissions
    const isOwner = report.reporter?.toString() === req.user?._id.toString();
    const isPrivileged = ['admin', 'moderator', 'analyst'].includes(req.user?.role);

    if (!isOwner && !isPrivileged) {
      return next(new AppError('You do not have permission to access this attachment', 403));
    }

    const attachment = report.attachments.find((a) => a.fileId === fileId);
    if (!attachment) {
      return next(new AppError('Attachment not found', 404));
    }

    // Generate new signed URL
    const bucket = getFirebaseStorage();
    const ext = path.extname(attachment.originalName);
    const fileName = `reports/${report.reportId}/${fileId}${ext}`;

    const [signedUrl] = await bucket.file(fileName).getSignedUrl({
      action: 'read',
      expires: Date.now() + 60 * 60 * 1000, // 1 hour
    });

    res.status(200).json({
      success: true,
      data: {
        downloadUrl: signedUrl,
        originalName: attachment.originalName,
        mimeType: attachment.mimeType,
        size: attachment.size,
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  upload,
  uploadAttachments,
  deleteAttachment,
  getAttachment,
  processAndUploadFile,
};
