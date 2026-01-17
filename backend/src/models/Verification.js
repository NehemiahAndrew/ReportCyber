const mongoose = require('mongoose');

const verificationSchema = new mongoose.Schema(
  {
    verificationId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      index: true,
    },
    reportId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Report',
      index: true,
    },
    fileHash: {
      type: String,
      required: true,
      index: true,
    },
    fileName: {
      type: String,
      required: true,
    },
    fileSize: {
      type: Number,
      required: true,
    },
    fileType: {
      type: String,
      required: true,
    },
    mediaType: {
      type: String,
      enum: ['image', 'video', 'file'],
      required: true,
    },
    results: {
      authenticityLevel: {
        type: String,
        enum: ['High', 'Medium', 'Low'],
        required: true,
      },
      authenticityDescription: String,
      metadataVerified: Boolean,
      editHistory: String,
      signatureValid: Boolean,
      manipulationScore: Number,
      metadata: mongoose.Schema.Types.Mixed,
    },
    summary: {
      authentic: Boolean,
      trustScore: {
        type: Number,
        min: 0,
        max: 100,
      },
      recommendations: [String],
    },
    status: {
      type: String,
      enum: ['completed', 'failed', 'pending'],
      default: 'completed',
    },
    isAnonymous: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
verificationSchema.index({ createdAt: -1 });
verificationSchema.index({ userId: 1, createdAt: -1 });
verificationSchema.index({ 'results.authenticityLevel': 1 });
verificationSchema.index({ 'summary.trustScore': -1 });

// Virtual for matched reports
verificationSchema.virtual('matchedReports', {
  ref: 'Verification',
  localField: 'fileHash',
  foreignField: 'fileHash',
});

// Methods
verificationSchema.methods.toJSON = function () {
  const obj = this.toObject();
  delete obj.__v;
  return obj;
};

// Statics
verificationSchema.statics.findByFileHash = function (fileHash) {
  return this.find({ fileHash }).populate('userId reportId');
};

verificationSchema.statics.getUserHistory = function (userId, limit = 20) {
  return this.find({ userId })
    .sort({ createdAt: -1 })
    .limit(limit)
    .select('-metadata');
};

verificationSchema.statics.getReportVerifications = function (reportId) {
  return this.find({ reportId }).sort({ createdAt: -1 });
};

const Verification = mongoose.model('Verification', verificationSchema);

module.exports = Verification;
