const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const reportSchema = new mongoose.Schema(
  {
    // Unique Report ID for tracking
    reportId: {
      type: String,
      unique: true,
      default: () => `RC-${Date.now().toString(36).toUpperCase()}-${uuidv4().split('-')[0].toUpperCase()}`,
    },
    
    // Reporter Information
    reporter: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null, // Null for anonymous reports
    },
    isAnonymous: {
      type: Boolean,
      default: false,
    },
    reporterEmail: {
      type: String, // For anonymous reporters who want updates
      trim: true,
    },
    
    // Incident Type and Category
    incidentType: {
      type: String,
      required: [true, 'Incident type is required'],
      enum: [
        'phishing_email',
        'phishing_sms',
        'phishing_social_media',
        'malware',
        'ransomware',
        'identity_theft',
        'online_fraud',
        'scam',
        'data_breach',
        'suspicious_website',
        'suspicious_link',
        'social_engineering',
        'cyberbullying',
        'harassment',
        'unauthorized_access',
        'ddos_attack',
        'cryptojacking',
        'other',
      ],
    },
    incidentSubtype: {
      type: String,
      trim: true,
    },
    
    // Incident Details
    title: {
      type: String,
      required: [true, 'Report title is required'],
      trim: true,
      maxlength: [200, 'Title cannot exceed 200 characters'],
    },
    description: {
      type: String,
      required: [true, 'Description is required'],
      maxlength: [10000, 'Description cannot exceed 10000 characters'],
    },
    
    // Temporal Information
    incidentDate: {
      type: Date,
      required: [true, 'Incident date is required'],
    },
    incidentTime: {
      type: String, // HH:MM format
    },
    
    // Severity
    severity: {
      type: String,
      enum: ['low', 'medium', 'high', 'critical'],
      default: 'medium',
    },
    
    // URLs and Links
    suspiciousUrls: [{
      url: {
        type: String,
        trim: true,
      },
      safetyCheck: {
        checked: { type: Boolean, default: false },
        isSafe: { type: Boolean, default: null },
        threats: [String],
        checkedAt: Date,
      },
    }],
    
    // Affected Platform/Service
    affectedPlatform: {
      type: String,
      trim: true,
    },
    affectedService: {
      type: String,
      trim: true,
    },
    
    // Geographic Information
    location: {
      country: String,
      region: String,
      city: String,
      coordinates: {
        latitude: Number,
        longitude: Number,
      },
      autoDetected: {
        type: Boolean,
        default: false,
      },
    },
    
    // Evidence/Attachments
    attachments: [{
      fileId: {
        type: String,
        required: true,
      },
      originalName: {
        type: String,
        required: true,
      },
      mimeType: {
        type: String,
        required: true,
      },
      size: {
        type: Number,
        required: true,
      },
      storageUrl: {
        type: String,
        required: true,
      },
      encryptionIv: {
        type: String,
      },
      fileHash: {
        type: String,
      },
      watermark: {
        type: mongoose.Schema.Types.Mixed,
      },
      malwareScan: {
        scanned: { type: Boolean, default: false },
        isSafe: { type: Boolean, default: null },
        scanResult: String,
        scannedAt: Date,
      },
      uploadedAt: {
        type: Date,
        default: Date.now,
      },
    }],
    
    // Report Status
    status: {
      type: String,
      enum: ['draft', 'submitted', 'under_review', 'verified', 'escalated', 'resolved', 'closed', 'rejected'],
      default: 'submitted',
    },
    statusHistory: [{
      status: String,
      changedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
      changedAt: {
        type: Date,
        default: Date.now,
      },
      notes: String,
    }],
    
    // Priority (set by analysts/moderators)
    priority: {
      type: String,
      enum: ['low', 'normal', 'high', 'urgent'],
      default: 'normal',
    },
    
    // Assignment
    assignedTo: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    assignedAt: Date,
    
    // Verification
    verification: {
      isVerified: {
        type: Boolean,
        default: false,
      },
      verifiedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
      verifiedAt: Date,
      verificationNotes: String,
    },
    
    // Evidence Verifications - References to Verification documents
    evidenceVerifications: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Verification',
    }],
    
    // Tags for categorization
    tags: [{
      type: String,
      trim: true,
      lowercase: true,
    }],
    
    // Internal Notes (visible to analysts/moderators only)
    internalNotes: [{
      note: String,
      createdBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
      createdAt: {
        type: Date,
        default: Date.now,
      },
    }],
    
    // Public Comments
    comments: [{
      comment: String,
      createdBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
      isPublic: {
        type: Boolean,
        default: true,
      },
      createdAt: {
        type: Date,
        default: Date.now,
      },
    }],
    
    // Related Reports
    relatedReports: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Report',
    }],
    
    // Escalation
    escalation: {
      isEscalated: {
        type: Boolean,
        default: false,
      },
      escalatedTo: String, // Authority name
      escalatedAt: Date,
      escalatedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
      escalationReason: String,
    },
    
    // Resolution
    resolution: {
      isResolved: {
        type: Boolean,
        default: false,
      },
      resolvedAt: Date,
      resolvedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
      resolutionSummary: String,
      outcome: {
        type: String,
        enum: ['confirmed_threat', 'false_positive', 'insufficient_evidence', 'duplicate', 'resolved_by_user', 'other'],
      },
    },
    
    // Auto-save Draft
    isDraft: {
      type: Boolean,
      default: false,
    },
    lastAutoSave: Date,
    
    // Consent
    dataProcessingConsent: {
      type: Boolean,
      required: [true, 'Data processing consent is required'],
    },
    
    // Analytics
    viewCount: {
      type: Number,
      default: 0,
    },
    
    // IP Address (for abuse prevention)
    submitterIp: {
      type: String,
      select: false,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes
reportSchema.index({ reportId: 1 });
reportSchema.index({ reporter: 1 });
reportSchema.index({ status: 1 });
reportSchema.index({ incidentType: 1 });
reportSchema.index({ severity: 1 });
reportSchema.index({ createdAt: -1 });
reportSchema.index({ incidentDate: -1 });
reportSchema.index({ tags: 1 });
reportSchema.index({ 'location.country': 1 });
reportSchema.index({ assignedTo: 1 });

// Text index for search
reportSchema.index({
  title: 'text',
  description: 'text',
  tags: 'text',
});

// Virtual for time since submission
reportSchema.virtual('timeSinceSubmission').get(function() {
  const now = new Date();
  const diff = now - this.createdAt;
  const days = Math.floor(diff / (1000 * 60 * 60 * 24));
  const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
  
  if (days > 0) {
    return `${days} day(s) ago`;
  }
  return `${hours} hour(s) ago`;
});

// Pre-save middleware to add status history
reportSchema.pre('save', function(next) {
  if (this.isModified('status') && !this.isNew) {
    this.statusHistory.push({
      status: this.status,
      changedAt: new Date(),
    });
  }
  next();
});

// Static method to get incident type categories
reportSchema.statics.getIncidentCategories = function() {
  return {
    phishing: ['phishing_email', 'phishing_sms', 'phishing_social_media'],
    malware: ['malware', 'ransomware'],
    fraud: ['identity_theft', 'online_fraud', 'scam'],
    security: ['data_breach', 'unauthorized_access', 'ddos_attack', 'cryptojacking'],
    suspicious: ['suspicious_website', 'suspicious_link', 'social_engineering'],
    harassment: ['cyberbullying', 'harassment'],
    other: ['other'],
  };
};

// Method to update status with history
reportSchema.methods.updateStatus = function(newStatus, userId, notes = '') {
  this.status = newStatus;
  this.statusHistory.push({
    status: newStatus,
    changedBy: userId,
    changedAt: new Date(),
    notes,
  });
};

const Report = mongoose.model('Report', reportSchema);

module.exports = Report;
