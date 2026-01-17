const User = require('../models/User');
const AuditLog = require('../models/AuditLog');
const Report = require('../models/Report');
const AppError = require('../utils/AppError');
const { getFirebaseStorage } = require('../config/firebase');
const sharp = require('sharp');

/**
 * Get user profile
 * GET /api/v1/users/profile
 */
exports.getProfile = async (req, res, next) => {
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
          notifications: user.notifications,
          createdAt: user.createdAt,
          lastLoginAt: user.lastLoginAt,
          twoFactorEnabled: user.twoFactorAuth?.enabled || false,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update user profile
 * PATCH /api/v1/users/profile
 */
exports.updateProfile = async (req, res, next) => {
  try {
    const allowedFields = ['firstName', 'lastName', 'bio', 'phone'];
    const updates = {};

    allowedFields.forEach((field) => {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    });

    const user = await User.findByIdAndUpdate(req.user._id, updates, {
      new: true,
      runValidators: true,
    });

    await AuditLog.log({
      action: 'user_profile_update',
      performedBy: req.user._id,
      targetUser: req.user._id,
      details: { updatedFields: Object.keys(updates) },
      ipAddress: req.ip,
    });

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
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
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Upload avatar
 * POST /api/v1/users/avatar
 */
exports.uploadAvatar = async (req, res, next) => {
  try {
    if (!req.file) {
      return next(new AppError('Please upload an image', 400));
    }

    // Resize and optimize image
    const resizedImage = await sharp(req.file.buffer)
      .resize(200, 200, {
        fit: 'cover',
        position: 'center',
      })
      .jpeg({ quality: 80 })
      .toBuffer();

    // Upload to Firebase Storage
    const bucket = getFirebaseStorage();
    const fileName = `avatars/${req.user._id}-${Date.now()}.jpg`;
    const file = bucket.file(fileName);

    await file.save(resizedImage, {
      metadata: {
        contentType: 'image/jpeg',
      },
    });

    // Make file public
    await file.makePublic();

    const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;

    // Delete old avatar if exists
    if (req.user.avatar && req.user.avatar.includes('storage.googleapis.com')) {
      try {
        const oldFileName = req.user.avatar.split('/').pop();
        await bucket.file(`avatars/${oldFileName}`).delete();
      } catch (error) {
        console.error('Failed to delete old avatar:', error);
      }
    }

    // Update user avatar
    req.user.avatar = publicUrl;
    await req.user.save({ validateBeforeSave: false });

    res.status(200).json({
      success: true,
      message: 'Avatar uploaded successfully',
      data: {
        avatar: publicUrl,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete avatar
 * DELETE /api/v1/users/avatar
 */
exports.deleteAvatar = async (req, res, next) => {
  try {
    if (!req.user.avatar) {
      return next(new AppError('No avatar to delete', 400));
    }

    // Delete from Firebase Storage
    if (req.user.avatar.includes('storage.googleapis.com')) {
      try {
        const bucket = getFirebaseStorage();
        const fileName = req.user.avatar.split('/').slice(-2).join('/');
        await bucket.file(fileName).delete();
      } catch (error) {
        console.error('Failed to delete avatar from storage:', error);
      }
    }

    req.user.avatar = null;
    await req.user.save({ validateBeforeSave: false });

    res.status(200).json({
      success: true,
      message: 'Avatar deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Change password
 * POST /api/v1/users/change-password
 */
exports.changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;

    const user = await User.findById(req.user._id).select('+password');

    if (!await user.comparePassword(currentPassword)) {
      return next(new AppError('Current password is incorrect', 401));
    }

    user.password = newPassword;
    user.refreshTokens = []; // Invalidate all sessions
    await user.save();

    await AuditLog.log({
      action: 'user_password_change',
      performedBy: req.user._id,
      targetUser: req.user._id,
      ipAddress: req.ip,
    });

    res.status(200).json({
      success: true,
      message: 'Password changed successfully. Please log in again.',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update notification preferences
 * PATCH /api/v1/users/notifications
 */
exports.updateNotificationPreferences = async (req, res, next) => {
  try {
    const { email, sms, inApp } = req.body;

    const updates = {};
    if (email) updates['notifications.email'] = email;
    if (sms) updates['notifications.sms'] = sms;
    if (inApp) updates['notifications.inApp'] = inApp;

    const user = await User.findByIdAndUpdate(
      req.user._id,
      { $set: updates },
      { new: true }
    );

    res.status(200).json({
      success: true,
      message: 'Notification preferences updated',
      data: {
        notifications: user.notifications,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get user activity history
 * GET /api/v1/users/activity
 */
exports.getActivityHistory = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 20;
    const skip = (page - 1) * limit;

    const logs = await AuditLog.find({
      $or: [
        { performedBy: req.user._id },
        { targetUser: req.user._id },
      ],
    })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .select('action details createdAt status');

    const total = await AuditLog.countDocuments({
      $or: [
        { performedBy: req.user._id },
        { targetUser: req.user._id },
      ],
    });

    res.status(200).json({
      success: true,
      data: {
        activities: logs,
        pagination: {
          currentPage: page,
          totalPages: Math.ceil(total / limit),
          totalItems: total,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get user's reports dashboard
 * GET /api/v1/users/reports
 */
exports.getUserReports = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 10;
    const skip = (page - 1) * limit;
    const status = req.query.status;

    const query = { reporter: req.user._id };
    if (status) {
      query.status = status;
    }

    const [reports, total, stats] = await Promise.all([
      Report.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .select('reportId title incidentType severity status createdAt'),
      Report.countDocuments(query),
      Report.aggregate([
        { $match: { reporter: req.user._id } },
        {
          $group: {
            _id: '$status',
            count: { $sum: 1 },
          },
        },
      ]),
    ]);

    // Transform stats to object
    const statusStats = {};
    stats.forEach((s) => {
      statusStats[s._id] = s.count;
    });

    res.status(200).json({
      success: true,
      data: {
        reports,
        stats: statusStats,
        pagination: {
          currentPage: page,
          totalPages: Math.ceil(total / limit),
          totalItems: total,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get active sessions
 * GET /api/v1/users/sessions
 */
exports.getActiveSessions = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id).select('refreshTokens');

    const sessions = user.refreshTokens
      .filter((t) => t.expiresAt > new Date())
      .map((t) => ({
        id: t._id,
        device: t.device,
        ip: t.ip,
        createdAt: t.createdAt,
        expiresAt: t.expiresAt,
      }));

    res.status(200).json({
      success: true,
      data: {
        sessions,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Revoke a session
 * DELETE /api/v1/users/sessions/:sessionId
 */
exports.revokeSession = async (req, res, next) => {
  try {
    const { sessionId } = req.params;

    await User.findByIdAndUpdate(req.user._id, {
      $pull: { refreshTokens: { _id: sessionId } },
    });

    res.status(200).json({
      success: true,
      message: 'Session revoked successfully',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete account
 * DELETE /api/v1/users/account
 */
exports.deleteAccount = async (req, res, next) => {
  try {
    const { password } = req.body;

    const user = await User.findById(req.user._id).select('+password');

    if (!await user.comparePassword(password)) {
      return next(new AppError('Password is incorrect', 401));
    }

    // Anonymize user data instead of hard delete
    user.email = `deleted_${user._id}@deleted.local`;
    user.firstName = 'Deleted';
    user.lastName = 'User';
    user.password = undefined;
    user.isActive = false;
    user.avatar = null;
    user.bio = null;
    user.phone = null;
    user.oauth = {};
    user.twoFactorAuth = { enabled: false };
    user.refreshTokens = [];
    user.notifications = {
      email: { reportUpdates: false, securityAlerts: false, newsletter: false, marketing: false },
      sms: { enabled: false, reportUpdates: false, securityAlerts: false },
      inApp: { reportUpdates: false, securityAlerts: false, communityUpdates: false },
    };

    await user.save({ validateBeforeSave: false });

    await AuditLog.log({
      action: 'admin_action',
      details: { action: 'account_deleted' },
      targetUser: req.user._id,
      ipAddress: req.ip,
    });

    res.status(200).json({
      success: true,
      message: 'Account deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};
