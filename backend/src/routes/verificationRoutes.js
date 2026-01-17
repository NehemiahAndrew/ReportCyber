const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const verificationController = require('../controllers/verificationController');
const { authenticate } = require('../middleware/auth');
const { validate } = require('../middleware/validation');
const { body } = require('express-validator');

const router = express.Router();

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, '../../uploads/temp');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Multer configuration for verification (disk storage)
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'verify-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const fileFilter = (req, file, cb) => {
  // Allow images, videos, and common file types
  const allowedMimeTypes = [
    'image/png',
    'image/jpeg',
    'image/jpg',
    'image/gif',
    'image/bmp',
    'image/webp',
    'video/mp4',
    'video/quicktime',
    'video/x-msvideo',
    'application/pdf',
  ];

  if (allowedMimeTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Only images, videos, and PDFs are allowed.'), false);
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 50 * 1024 * 1024, // 50MB max
  },
});

// Apply authentication to all verification routes
router.use(authenticate);

/**
 * @route   GET /api/v1/verify/history
 * @desc    Get user's verification history
 * @access  Private
 */
router.get('/history', verificationController.getVerificationHistory);

/**
 * @route   POST /api/v1/verify/evidence
 * @desc    Verify uploaded evidence file
 * @access  Private
 */
router.post(
  '/evidence',
  upload.single('file'),
  verificationController.verifyEvidence
);

/**
 * @route   POST /api/v1/verify/batch
 * @desc    Verify multiple evidence files
 * @access  Private
 */
router.post(
  '/batch',
  upload.array('files', 10), // Max 10 files
  verificationController.batchVerify
);

/**
 * @route   POST /api/v1/verify/compare
 * @desc    Compare file hash with database
 * @access  Private
 */
router.post(
  '/compare',
  body('fileHash')
    .notEmpty()
    .withMessage('File hash is required')
    .isLength({ min: 64, max: 64 })
    .withMessage('Invalid file hash format'),
  validate,
  verificationController.compareEvidence
);

module.exports = router;
