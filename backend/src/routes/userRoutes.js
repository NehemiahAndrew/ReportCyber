const express = require('express');
const userController = require('../controllers/userController');
const { authenticate } = require('../middleware/auth');
const { userValidation } = require('../middleware/validation');
const { upload } = require('../services/fileUploadService');

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Profile routes
router.get('/profile', userController.getProfile);
router.patch('/profile', userValidation.updateProfile, userController.updateProfile);

// Avatar routes
router.post('/avatar', upload.single('avatar'), userController.uploadAvatar);
router.delete('/avatar', userController.deleteAvatar);

// Password change
router.post('/change-password', userValidation.changePassword, userController.changePassword);

// Notification preferences
router.patch('/notifications', userController.updateNotificationPreferences);

// Activity history
router.get('/activity', userController.getActivityHistory);

// User's reports
router.get('/reports', userController.getUserReports);

// Session management
router.get('/sessions', userController.getActiveSessions);
router.delete('/sessions/:sessionId', userController.revokeSession);

// Delete account
router.delete('/account', userController.deleteAccount);

module.exports = router;
