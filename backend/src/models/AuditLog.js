const mongoose = require('mongoose');

const auditLogSchema = new mongoose.Schema(
  {
    action: {
      type: String,
      required: true,
      enum: [
        'user_register',
        'user_login',
        'user_logout',
        'user_login_failed',
        'user_password_reset',
        'user_password_change',
        'user_email_verified',
        'user_2fa_enabled',
        'user_2fa_disabled',
        'user_profile_update',
        'user_role_change',
        'user_blocked',
        'user_unblocked',
        'report_created',
        'report_updated',
        'report_deleted',
        'report_status_change',
        'report_assigned',
        'report_escalated',
        'report_verified',
        'report_comment_added',
        'file_uploaded',
        'file_deleted',
        'admin_action',
        'system_event',
      ],
    },
    performedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    targetUser: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    targetReport: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Report',
    },
    details: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
    ipAddress: String,
    userAgent: String,
    status: {
      type: String,
      enum: ['success', 'failure', 'pending'],
      default: 'success',
    },
  },
  {
    timestamps: true,
  }
);

// Indexes for querying
auditLogSchema.index({ action: 1 });
auditLogSchema.index({ performedBy: 1 });
auditLogSchema.index({ createdAt: -1 });
auditLogSchema.index({ targetUser: 1 });
auditLogSchema.index({ targetReport: 1 });

// Static method to log action
auditLogSchema.statics.log = async function(data) {
  try {
    const log = await this.create(data);
    return log;
  } catch (error) {
    console.error('Audit log error:', error);
    return null;
  }
};

const AuditLog = mongoose.model('AuditLog', auditLogSchema);

module.exports = AuditLog;
