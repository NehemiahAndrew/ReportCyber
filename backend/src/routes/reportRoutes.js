const express = require('express');
const reportController = require('../controllers/reportController');
const { authenticate, optionalAuth, restrictTo } = require('../middleware/auth');
const { reportValidation, paramValidation, queryValidation } = require('../middleware/validation');
const { reportLimiter, uploadLimiter } = require('../middleware/rateLimiter');
const { upload, uploadAttachments, deleteAttachment, getAttachment } = require('../services/fileUploadService');

const router = express.Router();

// Public routes
router.get('/categories', reportController.getCategories);
router.get('/track/:reportId', reportController.trackReport);

// Report submission (optional auth for anonymous reports)
router.post(
  '/',
  reportLimiter,
  optionalAuth,
  reportValidation.create,
  reportController.createReport
);

// Protected routes - require authentication
router.use(authenticate);

// Draft management
router.post('/draft', reportController.saveDraft);
router.get('/drafts', reportController.getDrafts);

// Get reports (with role-based filtering)
router.get('/', queryValidation.pagination, reportController.getReports);

// Statistics (analysts, moderators, admins)
router.get(
  '/stats',
  restrictTo('analyst', 'moderator', 'admin'),
  reportController.getReportStats
);

// Single report operations
router.get('/:id', paramValidation.mongoId, reportController.getReport);
router.patch('/:id', paramValidation.mongoId, reportValidation.update, reportController.updateReport);
router.delete('/:id', paramValidation.mongoId, reportController.deleteReport);

// Attachment routes
router.post(
  '/:id/attachments',
  uploadLimiter,
  paramValidation.mongoId,
  upload.array('files', 5),
  uploadAttachments
);
router.get('/:id/attachments/:fileId', paramValidation.mongoId, getAttachment);
router.delete('/:id/attachments/:fileId', paramValidation.mongoId, deleteAttachment);

// Comments
router.post('/:id/comments', paramValidation.mongoId, reportValidation.addComment, reportController.addComment);

// Analyst/Moderator/Admin routes
router.patch(
  '/:id/status',
  paramValidation.mongoId,
  restrictTo('analyst', 'moderator', 'admin'),
  reportValidation.updateStatus,
  reportController.updateReportStatus
);

router.patch(
  '/:id/assign',
  paramValidation.mongoId,
  restrictTo('moderator', 'admin'),
  reportController.assignReport
);

router.patch(
  '/:id/escalate',
  paramValidation.mongoId,
  restrictTo('analyst', 'moderator', 'admin'),
  reportController.escalateReport
);

router.post(
  '/:id/notes',
  paramValidation.mongoId,
  restrictTo('analyst', 'moderator', 'admin'),
  reportController.addInternalNote
);

module.exports = router;
