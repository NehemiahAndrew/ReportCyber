const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const speakeasy = require('speakeasy');
const QRCode = require('qrcode');
const User = require('../models/User');
const AuditLog = require('../models/AuditLog');
const AppError = require('../utils/AppError');
const config = require('../config/config');
const {
  sendVerificationEmail,
  sendPasswordResetEmail,
  send2FAEnabledEmail,
} = require('../utils/emailService');
const { generateSecureToken } = require('../utils/encryption');

// Generate JWT tokens
const generateTokens = (userId) => {
  const accessToken = jwt.sign({ id: userId }, config.jwt.accessSecret, {
    expiresIn: config.jwt.accessExpiry,
  });

  const refreshToken = jwt.sign({ id: userId }, config.jwt.refreshSecret, {
    expiresIn: config.jwt.refreshExpiry,
  });

  return { accessToken, refreshToken };
};

// Calculate refresh token expiry date
const getRefreshTokenExpiry = () => {
  const days = parseInt(config.jwt.refreshExpiry) || 7;
  return new Date(Date.now() + days * 24 * 60 * 60 * 1000);
};

/**
 * Register new user
 * POST /api/v1/auth/register
 */
exports.register = async (req, res, next) => {
  try {
    const { email, password, firstName, lastName } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return next(new AppError('Email already registered', 400));
    }

    // Create user
    const user = await User.create({
      email,
      password,
      firstName,
      lastName,
    });

    // Generate email verification token
    const verificationToken = user.createEmailVerificationToken();
    await user.save({ validateBeforeSave: false });

    // Send verification email
    try {
      await sendVerificationEmail(email, firstName, verificationToken);
    } catch (emailError) {
      console.error('Email sending failed:', emailError);
      // Don't fail registration if email fails
    }

    // Log the action
    await AuditLog.log({
      action: 'user_register',
      performedBy: user._id,
      targetUser: user._id,
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'],
    });

    res.status(201).json({
      success: true,
      message: 'Registration successful. Please check your email to verify your account.',
      data: {
        user: {
          id: user._id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Login user
 * POST /api/v1/auth/login
 */
exports.login = async (req, res, next) => {
  try {
    const { email, password, totpCode } = req.body;

    // Find user with password
    const user = await User.findOne({ email }).select('+password +twoFactorAuth.secret');

    if (!user || !user.password) {
      await AuditLog.log({
        action: 'user_login_failed',
        details: { email, reason: 'User not found or OAuth user' },
        ipAddress: req.ip,
        userAgent: req.headers['user-agent'],
        status: 'failure',
      });
      return next(new AppError('Invalid email or password', 401));
    }

    // Check password
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      // Log failed login
      user.loginHistory.push({
        ip: req.ip,
        device: req.headers['user-agent'],
        success: false,
      });
      await user.save({ validateBeforeSave: false });

      await AuditLog.log({
        action: 'user_login_failed',
        targetUser: user._id,
        details: { reason: 'Invalid password' },
        ipAddress: req.ip,
        userAgent: req.headers['user-agent'],
        status: 'failure',
      });

      return next(new AppError('Invalid email or password', 401));
    }

    // Check if account is blocked
    if (user.isBlocked) {
      return next(new AppError('Your account has been blocked. Please contact support.', 403));
    }

    // Check 2FA if enabled
    if (user.twoFactorAuth.enabled) {
      if (!totpCode) {
        return res.status(200).json({
          success: true,
          requires2FA: true,
          message: 'Please provide your 2FA code',
        });
      }

      const isValidTOTP = speakeasy.totp.verify({
        secret: user.twoFactorAuth.secret,
        encoding: 'base32',
        token: totpCode,
        window: 2,
      });

      if (!isValidTOTP) {
        // Check backup codes
        const backupCodeIndex = user.twoFactorAuth.backupCodes.findIndex(
          (bc) => bc.code === totpCode.toUpperCase() && !bc.used
        );

        if (backupCodeIndex === -1) {
          return next(new AppError('Invalid 2FA code', 401));
        }

        // Mark backup code as used
        user.twoFactorAuth.backupCodes[backupCodeIndex].used = true;
      }
    }

    // Check email verification
    if (!user.isEmailVerified) {
      return next(new AppError('Please verify your email before logging in', 401));
    }

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user._id);

    // Save refresh token
    user.refreshTokens.push({
      token: refreshToken,
      device: req.headers['user-agent'],
      ip: req.ip,
      expiresAt: getRefreshTokenExpiry(),
    });

    // Update login info
    user.lastLoginAt = new Date();
    user.loginHistory.push({
      ip: req.ip,
      device: req.headers['user-agent'],
      success: true,
    });

    // Keep only last 10 refresh tokens
    if (user.refreshTokens.length > 10) {
      user.refreshTokens = user.refreshTokens.slice(-10);
    }

    // Keep only last 50 login history entries
    if (user.loginHistory.length > 50) {
      user.loginHistory = user.loginHistory.slice(-50);
    }

    await user.save({ validateBeforeSave: false });

    // Log successful login
    await AuditLog.log({
      action: 'user_login',
      performedBy: user._id,
      targetUser: user._id,
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'],
    });

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: user._id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          avatar: user.avatar,
          role: user.role,
          reputation: user.reputation,
        },
        tokens: {
          accessToken,
          refreshToken,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Refresh access token
 * POST /api/v1/auth/refresh-token
 */
exports.refreshToken = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return next(new AppError('Refresh token is required', 400));
    }

    // Verify refresh token
    let decoded;
    try {
      decoded = jwt.verify(refreshToken, config.jwt.refreshSecret);
    } catch (error) {
      return next(new AppError('Invalid or expired refresh token', 401));
    }

    // Find user and check if token exists
    const user = await User.findById(decoded.id);
    if (!user) {
      return next(new AppError('User not found', 401));
    }

    const tokenExists = user.refreshTokens.find((t) => t.token === refreshToken);
    if (!tokenExists) {
      return next(new AppError('Invalid refresh token', 401));
    }

    // Check if token is expired
    if (tokenExists.expiresAt < new Date()) {
      // Remove expired token
      user.refreshTokens = user.refreshTokens.filter((t) => t.token !== refreshToken);
      await user.save({ validateBeforeSave: false });
      return next(new AppError('Refresh token expired', 401));
    }

    // Generate new tokens
    const tokens = generateTokens(user._id);

    // Replace old refresh token with new one
    user.refreshTokens = user.refreshTokens.filter((t) => t.token !== refreshToken);
    user.refreshTokens.push({
      token: tokens.refreshToken,
      device: req.headers['user-agent'],
      ip: req.ip,
      expiresAt: getRefreshTokenExpiry(),
    });

    await user.save({ validateBeforeSave: false });

    res.status(200).json({
      success: true,
      data: {
        tokens: {
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Logout user
 * POST /api/v1/auth/logout
 */
exports.logout = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (refreshToken && req.user) {
      // Remove specific refresh token
      req.user.refreshTokens = req.user.refreshTokens.filter(
        (t) => t.token !== refreshToken
      );
      await req.user.save({ validateBeforeSave: false });
    }

    await AuditLog.log({
      action: 'user_logout',
      performedBy: req.user?._id,
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'],
    });

    res.status(200).json({
      success: true,
      message: 'Logged out successfully',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Logout from all devices
 * POST /api/v1/auth/logout-all
 */
exports.logoutAll = async (req, res, next) => {
  try {
    req.user.refreshTokens = [];
    await req.user.save({ validateBeforeSave: false });

    res.status(200).json({
      success: true,
      message: 'Logged out from all devices',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Verify email
 * GET /api/v1/auth/verify-email/:token
 */
exports.verifyEmail = async (req, res, next) => {
  try {
    const hashedToken = crypto
      .createHash('sha256')
      .update(req.params.token)
      .digest('hex');

    const user = await User.findOne({
      emailVerificationToken: hashedToken,
      emailVerificationExpires: { $gt: Date.now() },
    });

    if (!user) {
      return next(new AppError('Token is invalid or has expired', 400));
    }

    user.isEmailVerified = true;
    user.emailVerificationToken = undefined;
    user.emailVerificationExpires = undefined;
    await user.save({ validateBeforeSave: false });

    await AuditLog.log({
      action: 'user_email_verified',
      performedBy: user._id,
      targetUser: user._id,
      ipAddress: req.ip,
    });

    res.status(200).json({
      success: true,
      message: 'Email verified successfully',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Resend verification email
 * POST /api/v1/auth/resend-verification
 */
exports.resendVerification = async (req, res, next) => {
  try {
    const { email } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return next(new AppError('No user found with this email', 404));
    }

    if (user.isEmailVerified) {
      return next(new AppError('Email is already verified', 400));
    }

    const verificationToken = user.createEmailVerificationToken();
    await user.save({ validateBeforeSave: false });

    await sendVerificationEmail(email, user.firstName, verificationToken);

    res.status(200).json({
      success: true,
      message: 'Verification email sent',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Forgot password
 * POST /api/v1/auth/forgot-password
 */
exports.forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      // Don't reveal if user exists
      return res.status(200).json({
        success: true,
        message: 'If an account exists with this email, a password reset link will be sent.',
      });
    }

    const resetToken = user.createPasswordResetToken();
    await user.save({ validateBeforeSave: false });

    try {
      await sendPasswordResetEmail(email, user.firstName, resetToken);
    } catch (error) {
      user.passwordResetToken = undefined;
      user.passwordResetExpires = undefined;
      await user.save({ validateBeforeSave: false });
      return next(new AppError('Error sending email. Please try again later.', 500));
    }

    res.status(200).json({
      success: true,
      message: 'If an account exists with this email, a password reset link will be sent.',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Reset password
 * POST /api/v1/auth/reset-password
 */
exports.resetPassword = async (req, res, next) => {
  try {
    const { token, password } = req.body;

    const hashedToken = crypto
      .createHash('sha256')
      .update(token)
      .digest('hex');

    const user = await User.findOne({
      passwordResetToken: hashedToken,
      passwordResetExpires: { $gt: Date.now() },
    });

    if (!user) {
      return next(new AppError('Token is invalid or has expired', 400));
    }

    user.password = password;
    user.passwordResetToken = undefined;
    user.passwordResetExpires = undefined;
    user.refreshTokens = []; // Invalidate all sessions
    await user.save();

    await AuditLog.log({
      action: 'user_password_reset',
      performedBy: user._id,
      targetUser: user._id,
      ipAddress: req.ip,
    });

    res.status(200).json({
      success: true,
      message: 'Password reset successful. Please login with your new password.',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Setup 2FA - Generate secret and QR code
 * POST /api/v1/auth/2fa/setup
 */
exports.setup2FA = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id).select('+twoFactorAuth.secret');

    if (user.twoFactorAuth.enabled) {
      return next(new AppError('2FA is already enabled', 400));
    }

    // Generate secret
    const secret = speakeasy.generateSecret({
      name: `ReportCyber:${user.email}`,
      length: 32,
    });

    // Save secret temporarily (not enabled yet)
    user.twoFactorAuth.secret = secret.base32;
    await user.save({ validateBeforeSave: false });

    // Generate QR code
    const qrCodeUrl = await QRCode.toDataURL(secret.otpauth_url);

    res.status(200).json({
      success: true,
      data: {
        secret: secret.base32,
        qrCode: qrCodeUrl,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Verify and enable 2FA
 * POST /api/v1/auth/2fa/verify
 */
exports.verify2FA = async (req, res, next) => {
  try {
    const { totpCode } = req.body;

    const user = await User.findById(req.user._id).select('+twoFactorAuth.secret');

    if (user.twoFactorAuth.enabled) {
      return next(new AppError('2FA is already enabled', 400));
    }

    if (!user.twoFactorAuth.secret) {
      return next(new AppError('Please setup 2FA first', 400));
    }

    // Verify TOTP
    const isValid = speakeasy.totp.verify({
      secret: user.twoFactorAuth.secret,
      encoding: 'base32',
      token: totpCode,
      window: 2,
    });

    if (!isValid) {
      return next(new AppError('Invalid verification code', 400));
    }

    // Enable 2FA and generate backup codes
    user.twoFactorAuth.enabled = true;
    const backupCodes = user.generateBackupCodes();
    await user.save({ validateBeforeSave: false });

    // Send confirmation email
    try {
      await send2FAEnabledEmail(user.email, user.firstName);
    } catch (error) {
      console.error('Failed to send 2FA enabled email:', error);
    }

    await AuditLog.log({
      action: 'user_2fa_enabled',
      performedBy: user._id,
      targetUser: user._id,
      ipAddress: req.ip,
    });

    res.status(200).json({
      success: true,
      message: '2FA enabled successfully',
      data: {
        backupCodes,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Disable 2FA
 * POST /api/v1/auth/2fa/disable
 */
exports.disable2FA = async (req, res, next) => {
  try {
    const { password, totpCode } = req.body;

    const user = await User.findById(req.user._id).select('+password +twoFactorAuth.secret');

    if (!user.twoFactorAuth.enabled) {
      return next(new AppError('2FA is not enabled', 400));
    }

    // Verify password
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return next(new AppError('Invalid password', 401));
    }

    // Verify TOTP
    const isValid = speakeasy.totp.verify({
      secret: user.twoFactorAuth.secret,
      encoding: 'base32',
      token: totpCode,
      window: 2,
    });

    if (!isValid) {
      return next(new AppError('Invalid 2FA code', 401));
    }

    // Disable 2FA
    user.twoFactorAuth.enabled = false;
    user.twoFactorAuth.secret = undefined;
    user.twoFactorAuth.backupCodes = [];
    await user.save({ validateBeforeSave: false });

    await AuditLog.log({
      action: 'user_2fa_disabled',
      performedBy: user._id,
      targetUser: user._id,
      ipAddress: req.ip,
    });

    res.status(200).json({
      success: true,
      message: '2FA disabled successfully',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get new backup codes
 * POST /api/v1/auth/2fa/backup-codes
 */
exports.generateNewBackupCodes = async (req, res, next) => {
  try {
    const { password } = req.body;

    const user = await User.findById(req.user._id).select('+password');

    if (!user.twoFactorAuth.enabled) {
      return next(new AppError('2FA is not enabled', 400));
    }

    // Verify password
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return next(new AppError('Invalid password', 401));
    }

    const backupCodes = user.generateBackupCodes();
    await user.save({ validateBeforeSave: false });

    res.status(200).json({
      success: true,
      message: 'New backup codes generated',
      data: {
        backupCodes,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get current user info
 * GET /api/v1/auth/me
 */
exports.getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);

    res.status(200).json({
      success: true,
      data: {
        user: {
          id: user._id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          fullName: user.fullName,
          avatar: user.avatar,
          bio: user.bio,
          phone: user.phone,
          role: user.role,
          reputation: user.reputation,
          isEmailVerified: user.isEmailVerified,
          twoFactorEnabled: user.twoFactorAuth.enabled,
          notifications: user.notifications,
          createdAt: user.createdAt,
          lastLoginAt: user.lastLoginAt,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};
