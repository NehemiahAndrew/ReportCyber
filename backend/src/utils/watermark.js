const sharp = require('sharp');
const crypto = require('crypto');

/**
 * Add invisible watermark to image
 * @param {Buffer} imageBuffer - Original image buffer
 * @param {string} watermarkText - Text to embed as watermark
 * @returns {Promise<Buffer>} - Watermarked image buffer
 */
const addWatermark = async (imageBuffer, watermarkText) => {
  try {
    const image = sharp(imageBuffer);
    const metadata = await image.metadata();
    
    // Create watermark text
    const timestamp = new Date().toISOString();
    const watermarkData = `${watermarkText} | ${timestamp}`;
    
    // Create SVG with semi-transparent watermark
    const svgWatermark = `
      <svg width="${metadata.width}" height="${metadata.height}">
        <style>
          .watermark {
            fill: rgba(255, 255, 255, 0.05);
            font-family: Arial, sans-serif;
            font-size: 12px;
          }
        </style>
        <text x="10" y="${metadata.height - 10}" class="watermark">${watermarkData}</text>
      </svg>
    `;
    
    const watermarkedImage = await image
      .composite([
        {
          input: Buffer.from(svgWatermark),
          gravity: 'southeast',
        },
      ])
      .toBuffer();
    
    return watermarkedImage;
  } catch (error) {
    console.error('Watermarking error:', error);
    return imageBuffer; // Return original if watermarking fails
  }
};

/**
 * Add metadata watermark to file
 * @param {Object} fileInfo - File information
 * @returns {Object} - Watermark metadata
 */
const generateMetadataWatermark = (fileInfo) => {
  const { userId, reportId, originalName, uploadTime } = fileInfo;
  
  const watermarkPayload = {
    userId: userId || 'anonymous',
    reportId,
    originalName,
    uploadTime: uploadTime || new Date().toISOString(),
    platformId: 'ReportCyber',
    hash: crypto.randomBytes(8).toString('hex'),
  };
  
  return watermarkPayload;
};

/**
 * Verify watermark metadata
 * @param {Object} metadata - Watermark metadata
 * @returns {boolean} - Is valid
 */
const verifyWatermark = (metadata) => {
  if (!metadata || !metadata.platformId) {
    return false;
  }
  return metadata.platformId === 'ReportCyber';
};

/**
 * Strip EXIF data from image for privacy
 * @param {Buffer} imageBuffer - Image buffer
 * @returns {Promise<Buffer>} - Image without EXIF
 */
const stripExifData = async (imageBuffer) => {
  try {
    const strippedImage = await sharp(imageBuffer)
      .rotate() // Auto-rotate based on EXIF, then strip
      .toBuffer();
    return strippedImage;
  } catch (error) {
    console.error('EXIF stripping error:', error);
    return imageBuffer;
  }
};

/**
 * Resize image if too large
 * @param {Buffer} imageBuffer - Image buffer
 * @param {Object} options - Resize options
 * @returns {Promise<Buffer>} - Resized image
 */
const resizeImage = async (imageBuffer, options = {}) => {
  const { maxWidth = 2048, maxHeight = 2048, quality = 85 } = options;
  
  try {
    const image = sharp(imageBuffer);
    const metadata = await image.metadata();
    
    if (metadata.width > maxWidth || metadata.height > maxHeight) {
      return await image
        .resize(maxWidth, maxHeight, {
          fit: 'inside',
          withoutEnlargement: true,
        })
        .jpeg({ quality })
        .toBuffer();
    }
    
    return imageBuffer;
  } catch (error) {
    console.error('Image resize error:', error);
    return imageBuffer;
  }
};

module.exports = {
  addWatermark,
  generateMetadataWatermark,
  verifyWatermark,
  stripExifData,
  resizeImage,
};
