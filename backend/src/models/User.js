const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

const userSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
      match: [/^\S+@\S+\.\S+$/, 'Please enter a valid email'],
    },
    password: {
      type: String,
      minlength: [8, 'Password must be at least 8 characters'],
      select: false,
    },
    firstName: {
      type: String,
      trim: true,
      maxlength: [50, 'First name cannot exceed 50 characters'],
    },
    lastName: {
      type: String,
      trim: true,
      maxlength: [50, 'Last name cannot exceed 50 characters'],
    },
    avatar: {
      type: String,
      default: null,
    },
    bio: {
      type: String,
      maxlength: [500, 'Bio cannot exceed 500 characters'],
    },
    phone: {
      type: String,
      trim: true,
    },
    role: {
      type: String,
      enum: ['anonymous', 'user', 'analyst', 'moderator', 'admin'],
      default: 'user',
    },
    isEmailVerified: {
      type: Boolean,
      default: false,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    isBlocked: {
      type: Boolean,
      default: false,
    },
    
    // Trust/Reputation System
    reputation: {
      score: {
        type: Number,
        default: 0,
        min: 0,
      },
      totalReports: {
        type: Number,
        default: 0,
      },
      verifiedReports: {
        type: Number,
        default: 0,
      },
      rejectedReports: {
        type: Number,
        default: 0,
      },
      level: {
        type: String,
        enum: ['newcomer', 'contributor', 'trusted', 'expert', 'veteran'],
        default: 'newcomer',
      },
    },
    
    // Two-Factor Authentication
    twoFactorAuth: {
      enabled: {
        type: Boolean,
        default: false,
      },
      secret: {
        type: String,
        select: false,
      },
      backupCodes: [{
        code: String,
        used: {
          type: Boolean,
          default: false,
        },
      }],
    },
    
    // OAuth Providers
    oauth: {
      google: {
        id: String,
        email: String,
      },
      github: {
        id: String,
        username: String,
      },
    },
    
    // Notification Preferences
    notifications: {
      email: {
        reportUpdates: { type: Boolean, default: true },
        securityAlerts: { type: Boolean, default: true },
        newsletter: { type: Boolean, default: false },
        marketing: { type: Boolean, default: false },
      },
      sms: {
        enabled: { type: Boolean, default: false },
        reportUpdates: { type: Boolean, default: false },
        securityAlerts: { type: Boolean, default: true },
      },
      inApp: {
        reportUpdates: { type: Boolean, default: true },
        securityAlerts: { type: Boolean, default: true },
        communityUpdates: { type: Boolean, default: true },
      },
    },
    
    // Security
    passwordChangedAt: Date,
    passwordResetToken: String,
    passwordResetExpires: Date,
    emailVerificationToken: String,
    emailVerificationExpires: Date,
    
    // Session Management
    refreshTokens: [{
      token: String,
      device: String,
      ip: String,
      createdAt: {
        type: Date,
        default: Date.now,
      },
      expiresAt: Date,
    }],
    
    // Login History
    loginHistory: [{
      timestamp: {
        type: Date,
        default: Date.now,
      },
      ip: String,
      device: String,
      location: String,
      success: Boolean,
    }],
    
    lastLoginAt: Date,
    lastActiveAt: Date,
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Virtual for full name
userSchema.virtual('fullName').get(function() {
  if (this.firstName && this.lastName) {
    return `${this.firstName} ${this.lastName}`;
  }
  return this.firstName || this.email.split('@')[0];
});

// Index for search
userSchema.index({ email: 1 });
userSchema.index({ role: 1 });
userSchema.index({ 'reputation.score': -1 });

// Pre-save middleware to hash password
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  if (this.password) {
    this.password = await bcrypt.hash(this.password, 12);
    this.passwordChangedAt = Date.now() - 1000;
  }
  next();
});

// Method to compare passwords
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Method to check if password was changed after token was issued
userSchema.methods.changedPasswordAfter = function(JWTTimestamp) {
  if (this.passwordChangedAt) {
    const changedTimestamp = parseInt(this.passwordChangedAt.getTime() / 1000, 10);
    return JWTTimestamp < changedTimestamp;
  }
  return false;
};

// Method to generate password reset token
userSchema.methods.createPasswordResetToken = function() {
  const resetToken = crypto.randomBytes(32).toString('hex');
  
  this.passwordResetToken = crypto
    .createHash('sha256')
    .update(resetToken)
    .digest('hex');
  
  this.passwordResetExpires = Date.now() + 60 * 60 * 1000; // 1 hour
  
  return resetToken;
};

// Method to generate email verification token
userSchema.methods.createEmailVerificationToken = function() {
  const verificationToken = crypto.randomBytes(32).toString('hex');
  
  this.emailVerificationToken = crypto
    .createHash('sha256')
    .update(verificationToken)
    .digest('hex');
  
  this.emailVerificationExpires = Date.now() + 24 * 60 * 60 * 1000; // 24 hours
  
  return verificationToken;
};

// Method to update reputation
userSchema.methods.updateReputation = function(reportStatus) {
  this.reputation.totalReports += 1;
  
  if (reportStatus === 'verified') {
    this.reputation.verifiedReports += 1;
    this.reputation.score += 10;
  } else if (reportStatus === 'rejected') {
    this.reputation.rejectedReports += 1;
    this.reputation.score = Math.max(0, this.reputation.score - 5);
  }
  
  // Update level based on score
  if (this.reputation.score >= 500) {
    this.reputation.level = 'veteran';
  } else if (this.reputation.score >= 200) {
    this.reputation.level = 'expert';
  } else if (this.reputation.score >= 100) {
    this.reputation.level = 'trusted';
  } else if (this.reputation.score >= 30) {
    this.reputation.level = 'contributor';
  } else {
    this.reputation.level = 'newcomer';
  }
};

// Method to generate 2FA backup codes
userSchema.methods.generateBackupCodes = function() {
  const codes = [];
  for (let i = 0; i < 10; i++) {
    codes.push({
      code: crypto.randomBytes(4).toString('hex').toUpperCase(),
      used: false,
    });
  }
  this.twoFactorAuth.backupCodes = codes;
  return codes.map(c => c.code);
};

const User = mongoose.model('User', userSchema);

module.exports = User;
