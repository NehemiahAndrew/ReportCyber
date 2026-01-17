const express = require('express');
const passport = require('passport');
const authController = require('../controllers/authController');
const { authenticate } = require('../middleware/auth');
const { userValidation } = require('../middleware/validation');
const { authLimiter, passwordResetLimiter } = require('../middleware/rateLimiter');
const config = require('../config/config');

const router = express.Router();

// Registration
router.post('/register', authLimiter, userValidation.register, authController.register);

// Login
router.post('/login', authLimiter, userValidation.login, authController.login);

// Refresh token
router.post('/refresh-token', authController.refreshToken);

// Logout
router.post('/logout', authenticate, authController.logout);
router.post('/logout-all', authenticate, authController.logoutAll);

// Email verification
router.get('/verify-email/:token', authController.verifyEmail);
router.post('/resend-verification', authLimiter, authController.resendVerification);

// Password reset
router.post('/forgot-password', passwordResetLimiter, authController.forgotPassword);
router.post('/reset-password', passwordResetLimiter, userValidation.resetPassword, authController.resetPassword);

// 2FA routes
router.post('/2fa/setup', authenticate, authController.setup2FA);
router.post('/2fa/verify', authenticate, authController.verify2FA);
router.post('/2fa/disable', authenticate, authController.disable2FA);
router.post('/2fa/backup-codes', authenticate, authController.generateNewBackupCodes);

// Get current user
router.get('/me', authenticate, authController.getMe);

// OAuth routes
// Google OAuth
router.get(
  '/google',
  passport.authenticate('google', { scope: ['profile', 'email'] })
);

router.get(
  '/google/callback',
  passport.authenticate('google', { session: false, failureRedirect: `${config.frontendUrl}/login?error=oauth_failed` }),
  (req, res) => {
    // Generate tokens and redirect to frontend
    const jwt = require('jsonwebtoken');
    const accessToken = jwt.sign({ id: req.user._id }, config.jwt.accessSecret, {
      expiresIn: config.jwt.accessExpiry,
    });
    const refreshToken = jwt.sign({ id: req.user._id }, config.jwt.refreshSecret, {
      expiresIn: config.jwt.refreshExpiry,
    });

    // Redirect with tokens
    res.redirect(
      `${config.frontendUrl}/oauth/callback?accessToken=${accessToken}&refreshToken=${refreshToken}`
    );
  }
);

// GitHub OAuth
router.get(
  '/github',
  passport.authenticate('github', { scope: ['user:email'] })
);

router.get(
  '/github/callback',
  passport.authenticate('github', { session: false, failureRedirect: `${config.frontendUrl}/login?error=oauth_failed` }),
  (req, res) => {
    // Generate tokens and redirect to frontend
    const jwt = require('jsonwebtoken');
    const accessToken = jwt.sign({ id: req.user._id }, config.jwt.accessSecret, {
      expiresIn: config.jwt.accessExpiry,
    });
    const refreshToken = jwt.sign({ id: req.user._id }, config.jwt.refreshSecret, {
      expiresIn: config.jwt.refreshExpiry,
    });

    // Redirect with tokens
    res.redirect(
      `${config.frontendUrl}/oauth/callback?accessToken=${accessToken}&refreshToken=${refreshToken}`
    );
  }
);

module.exports = router;
