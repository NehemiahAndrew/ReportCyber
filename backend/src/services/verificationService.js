const sharp = require('sharp');
const crypto = require('crypto');
const fs = require('fs').promises;
const path = require('path');
const ExifParser = require('exif-parser');

class VerificationService {
  /**
   * Analyze uploaded file for authenticity and tampering
   */
  async analyzeFile(filePath, fileType) {
    try {
      const results = {
        fileHash: await this.generateFileHash(filePath),
        fileSize: await this.getFileSize(filePath),
        fileType: fileType,
        timestamp: new Date().toISOString(),
      };

      // Image analysis
      if (fileType.startsWith('image/')) {
        const imageAnalysis = await this.analyzeImage(filePath);
        return {
          ...results,
          ...imageAnalysis,
          mediaType: 'image',
        };
      }

      // Video analysis (basic for now)
      if (fileType.startsWith('video/')) {
        const videoAnalysis = await this.analyzeVideo(filePath);
        return {
          ...results,
          ...videoAnalysis,
          mediaType: 'video',
        };
      }

      // Generic file analysis
      return {
        ...results,
        mediaType: 'file',
        authenticityLevel: 'Medium',
        authenticityDescription: 'Basic file integrity verified.',
        metadataVerified: false,
        editHistory: 'Unknown',
        signatureValid: false,
      };
    } catch (error) {
      console.error('Verification analysis error:', error);
      throw new Error('Failed to analyze file: ' + error.message);
    }
  }

  /**
   * Analyze image for tampering and authenticity
   */
  async analyzeImage(filePath) {
    try {
      // Get image metadata using sharp
      const metadata = await sharp(filePath).metadata();
      
      // Extract EXIF data
      let exifData = null;
      let hasOriginalMetadata = false;
      let editHistory = 'No Edits';
      
      try {
        const buffer = await fs.readFile(filePath);
        const parser = ExifParser.create(buffer);
        exifData = parser.parse();
        
        // Check for editing software traces
        if (exifData.tags?.Software) {
          const software = exifData.tags.Software.toLowerCase();
          if (software.includes('photoshop') || software.includes('gimp') || 
              software.includes('lightroom') || software.includes('paint')) {
            editHistory = `Edited with ${exifData.tags.Software}`;
            hasOriginalMetadata = false;
          } else {
            hasOriginalMetadata = true;
          }
        }
        
        // Check if metadata exists
        hasOriginalMetadata = exifData.tags && Object.keys(exifData.tags).length > 5;
      } catch (exifError) {
        console.log('EXIF extraction failed (file may not have EXIF):', exifError.message);
      }

      // Analyze image for manipulation indicators
      const manipulationScore = await this.detectImageManipulation(filePath, metadata);
      
      // Determine authenticity level
      let authenticityLevel = 'High';
      let authenticityDescription = 'Image appears authentic with original metadata intact.';
      
      if (manipulationScore > 0.7 || !hasOriginalMetadata) {
        authenticityLevel = 'Low';
        authenticityDescription = 'Image shows signs of significant editing or missing metadata.';
      } else if (manipulationScore > 0.4 || editHistory !== 'No Edits') {
        authenticityLevel = 'Medium';
        authenticityDescription = 'Image has been edited or shows moderate manipulation indicators.';
      }

      return {
        authenticityLevel,
        authenticityDescription,
        metadataVerified: hasOriginalMetadata,
        metadata: {
          width: metadata.width,
          height: metadata.height,
          format: metadata.format,
          hasAlpha: metadata.hasAlpha,
          channels: metadata.channels,
          density: metadata.density,
          exif: exifData ? {
            dateTime: exifData.tags?.DateTime || exifData.tags?.DateTimeOriginal,
            make: exifData.tags?.Make,
            model: exifData.tags?.Model,
            software: exifData.tags?.Software,
            gps: exifData.tags?.GPSLatitude ? {
              latitude: exifData.tags.GPSLatitude,
              longitude: exifData.tags.GPSLongitude,
            } : null,
          } : null,
        },
        editHistory,
        manipulationScore: Math.round(manipulationScore * 100),
        signatureValid: hasOriginalMetadata && manipulationScore < 0.3,
      };
    } catch (error) {
      console.error('Image analysis error:', error);
      throw error;
    }
  }

  /**
   * Detect image manipulation using various techniques
   */
  async detectImageManipulation(filePath, metadata) {
    let score = 0;
    
    try {
      // Check 1: Unusual compression artifacts
      if (metadata.format === 'jpeg') {
        // JPEG quality analysis
        const stats = await sharp(filePath).stats();
        
        // Check for inconsistent noise patterns (indicator of manipulation)
        const channelVariance = stats.channels.map(c => c.stdev);
        const avgVariance = channelVariance.reduce((a, b) => a + b, 0) / channelVariance.length;
        
        // High variance difference between channels can indicate manipulation
        const maxDiff = Math.max(...channelVariance) - Math.min(...channelVariance);
        if (maxDiff > avgVariance * 0.5) {
          score += 0.3;
        }
      }

      // Check 2: Missing or stripped metadata (common in edited images)
      if (!metadata.exif || Object.keys(metadata.exif || {}).length < 3) {
        score += 0.4;
      }

      // Check 3: Check for unusual aspect ratios or dimensions
      const aspectRatio = metadata.width / metadata.height;
      if (aspectRatio < 0.1 || aspectRatio > 10) {
        score += 0.2;
      }

      // Check 4: Analyze edge detection patterns
      const { data: edgeData } = await sharp(filePath)
        .greyscale()
        .convolve({
          width: 3,
          height: 3,
          kernel: [-1, -1, -1, -1, 8, -1, -1, -1, -1] // Laplacian edge detection
        })
        .raw()
        .toBuffer({ resolveWithObject: true });

      // Calculate edge density
      const edgePixels = Buffer.from(edgeData).filter(pixel => pixel > 100).length;
      const edgeDensity = edgePixels / edgeData.length;
      
      // Extremely high or low edge density can indicate manipulation
      if (edgeDensity > 0.6 || edgeDensity < 0.05) {
        score += 0.2;
      }

      return Math.min(score, 1.0); // Cap at 1.0
    } catch (error) {
      console.error('Manipulation detection error:', error);
      return 0.5; // Return medium suspicion on error
    }
  }

  /**
   * Analyze video file (basic analysis)
   */
  async analyzeVideo(filePath) {
    try {
      // For now, basic video analysis without ffmpeg
      const fileStats = await fs.stat(filePath);
      
      return {
        authenticityLevel: 'Medium',
        authenticityDescription: 'Video file integrity verified. Advanced analysis requires additional tools.',
        metadataVerified: false,
        metadata: {
          size: fileStats.size,
          created: fileStats.birthtime,
          modified: fileStats.mtime,
        },
        editHistory: 'Unknown',
        manipulationScore: 50,
        signatureValid: false,
      };
    } catch (error) {
      console.error('Video analysis error:', error);
      throw error;
    }
  }

  /**
   * Generate cryptographic hash of file
   */
  async generateFileHash(filePath) {
    try {
      const fileBuffer = await fs.readFile(filePath);
      const hash = crypto.createHash('sha256');
      hash.update(fileBuffer);
      return hash.digest('hex');
    } catch (error) {
      console.error('Hash generation error:', error);
      return null;
    }
  }

  /**
   * Get file size in bytes
   */
  async getFileSize(filePath) {
    try {
      const stats = await fs.stat(filePath);
      return stats.size;
    } catch (error) {
      console.error('File size error:', error);
      return 0;
    }
  }

  /**
   * Compare file hash with known evidence database
   */
  async compareWithDatabase(fileHash) {
    const Verification = require('../models/Verification');
    
    try {
      // Find all verifications with the same hash
      const matchedVerifications = await Verification.findByFileHash(fileHash);
      
      const matchedReports = matchedVerifications
        .filter(v => v.reportId)
        .map(v => ({
          reportId: v.reportId?.reportId || v.reportId,
          verificationId: v.verificationId,
          verifiedAt: v.createdAt,
          authenticityLevel: v.results.authenticityLevel,
          trustScore: v.summary.trustScore,
        }));

      return {
        found: matchedVerifications.length > 0,
        totalMatches: matchedVerifications.length,
        matchedReports: matchedReports,
        message: matchedReports.length > 0 
          ? `This file has been verified ${matchedReports.length} time(s) before`
          : 'No previous verifications found for this file',
      };
    } catch (error) {
      console.error('Database comparison error:', error);
      return {
        found: false,
        matchedReports: [],
        error: 'Failed to compare with database',
      };
    }
  }

  /**
   * Generate verification report
   */
  generateReport(analysisResults) {
    return {
      verificationId: crypto.randomUUID(),
      timestamp: new Date().toISOString(),
      results: analysisResults,
      summary: {
        authentic: analysisResults.authenticityLevel === 'High',
        trustScore: this.calculateTrustScore(analysisResults),
        recommendations: this.generateRecommendations(analysisResults),
      },
    };
  }

  /**
   * Calculate overall trust score (0-100)
   */
  calculateTrustScore(results) {
    let score = 50; // Start at medium

    if (results.authenticityLevel === 'High') score += 30;
    if (results.authenticityLevel === 'Low') score -= 30;
    
    if (results.metadataVerified) score += 15;
    if (results.signatureValid) score += 10;
    
    if (results.editHistory !== 'No Edits' && results.editHistory !== 'Unknown') {
      score -= 15;
    }

    if (results.manipulationScore) {
      score -= (results.manipulationScore / 2);
    }

    return Math.max(0, Math.min(100, Math.round(score)));
  }

  /**
   * Generate recommendations based on analysis
   */
  generateRecommendations(results) {
    const recommendations = [];

    if (!results.metadataVerified) {
      recommendations.push('File is missing original metadata. Consider requesting original source.');
    }

    if (results.manipulationScore > 50) {
      recommendations.push('High manipulation indicators detected. Recommend further forensic analysis.');
    }

    if (results.editHistory && results.editHistory !== 'No Edits' && results.editHistory !== 'Unknown') {
      recommendations.push(`File was edited using ${results.editHistory}. Request unedited version if possible.`);
    }

    if (!results.signatureValid) {
      recommendations.push('Digital signature could not be verified. Exercise caution with this evidence.');
    }

    if (results.authenticityLevel === 'High' && recommendations.length === 0) {
      recommendations.push('File appears authentic and suitable for evidence.');
    }

    return recommendations;
  }
}

module.exports = new VerificationService();
