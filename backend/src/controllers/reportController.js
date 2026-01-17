const Report = require('../models/Report');
const User = require('../models/User');
const Notification = require('../models/Notification');
const AuditLog = require('../models/AuditLog');
const AppError = require('../utils/AppError');
const { sendReportConfirmationEmail, sendReportStatusUpdateEmail } = require('../utils/emailService');
const { checkUrlSafety } = require('../services/urlSafetyService');

/**
 * Create a new report
 * POST /api/v1/reports
 */
exports.createReport = async (req, res, next) => {
  try {
    const {
      incidentType,
      incidentSubtype,
      title,
      description,
      incidentDate,
      incidentTime,
      severity,
      suspiciousUrls,
      affectedPlatform,
      affectedService,
      location,
      isAnonymous,
      reporterEmail,
      tags,
      dataProcessingConsent,
    } = req.body;

    // Create report data
    const reportData = {
      incidentType,
      incidentSubtype,
      title,
      description,
      incidentDate,
      incidentTime,
      severity: severity || 'medium',
      affectedPlatform,
      affectedService,
      location,
      tags,
      dataProcessingConsent,
      isAnonymous: isAnonymous || !req.user,
      submitterIp: req.ip,
    };

    // Set reporter if authenticated and not anonymous
    if (req.user && !isAnonymous) {
      reportData.reporter = req.user._id;
    } else if (reporterEmail) {
      reportData.reporterEmail = reporterEmail;
    }

    // Process suspicious URLs
    if (suspiciousUrls && suspiciousUrls.length > 0) {
      reportData.suspiciousUrls = await Promise.all(
        suspiciousUrls.map(async (urlObj) => {
          const safetyCheck = await checkUrlSafety(urlObj.url);
          return {
            url: urlObj.url,
            safetyCheck: {
              checked: true,
              isSafe: safetyCheck.isSafe,
              threats: safetyCheck.threats || [],
              checkedAt: new Date(),
            },
          };
        })
      );
    }

    // Add initial status history
    reportData.statusHistory = [{
      status: 'submitted',
      changedAt: new Date(),
      notes: 'Report submitted',
    }];

    const report = await Report.create(reportData);

    // Update user reputation if authenticated
    if (req.user) {
      req.user.reputation.totalReports += 1;
      await req.user.save({ validateBeforeSave: false });
    }

    // Send confirmation email
    const emailTo = req.user?.email || reporterEmail;
    if (emailTo) {
      try {
        await sendReportConfirmationEmail(
          emailTo,
          req.user?.firstName || null,
          report.reportId,
          incidentType.replace(/_/g, ' ')
        );
      } catch (emailError) {
        console.error('Failed to send confirmation email:', emailError);
      }
    }

    // Create audit log
    await AuditLog.log({
      action: 'report_created',
      performedBy: req.user?._id,
      targetReport: report._id,
      details: { reportId: report.reportId, incidentType },
      ipAddress: req.ip,
    });

    res.status(201).json({
      success: true,
      message: 'Report submitted successfully',
      data: {
        report: {
          id: report._id,
          reportId: report.reportId,
          title: report.title,
          incidentType: report.incidentType,
          severity: report.severity,
          status: report.status,
          createdAt: report.createdAt,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get all reports (with filtering and pagination)
 * GET /api/v1/reports
 */
exports.getReports = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 20;
    const skip = (page - 1) * limit;

    // Build query
    const query = {};

    // Filter by status
    if (req.query.status) {
      query.status = req.query.status;
    }

    // Filter by incident type
    if (req.query.incidentType) {
      query.incidentType = req.query.incidentType;
    }

    // Filter by severity
    if (req.query.severity) {
      query.severity = req.query.severity;
    }

    // Filter by date range
    if (req.query.startDate || req.query.endDate) {
      query.incidentDate = {};
      if (req.query.startDate) {
        query.incidentDate.$gte = new Date(req.query.startDate);
      }
      if (req.query.endDate) {
        query.incidentDate.$lte = new Date(req.query.endDate);
      }
    }

    // Text search
    if (req.query.search) {
      query.$text = { $search: req.query.search };
    }

    // For regular users, only show their own reports
    if (req.user.role === 'user') {
      query.reporter = req.user._id;
    }

    // For analysts, show assigned reports or unassigned
    if (req.user.role === 'analyst') {
      query.$or = [
        { assignedTo: req.user._id },
        { assignedTo: null, status: 'submitted' },
      ];
    }

    const [reports, total] = await Promise.all([
      Report.find(query)
        .populate('reporter', 'firstName lastName email reputation.level')
        .populate('assignedTo', 'firstName lastName')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .select('-internalNotes -submitterIp'),
      Report.countDocuments(query),
    ]);

    res.status(200).json({
      success: true,
      data: {
        reports,
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
 * Get single report by ID
 * GET /api/v1/reports/:id
 */
exports.getReport = async (req, res, next) => {
  try {
    const report = await Report.findById(req.params.id)
      .populate('reporter', 'firstName lastName email avatar reputation')
      .populate('assignedTo', 'firstName lastName email')
      .populate('verification.verifiedBy', 'firstName lastName')
      .populate('comments.createdBy', 'firstName lastName avatar')
      .populate('statusHistory.changedBy', 'firstName lastName');

    if (!report) {
      return next(new AppError('Report not found', 404));
    }

    // Check access permissions
    const isOwner = report.reporter?._id.toString() === req.user?._id.toString();
    const isPrivileged = ['admin', 'moderator', 'analyst'].includes(req.user?.role);

    if (!isOwner && !isPrivileged && !report.isAnonymous) {
      return next(new AppError('You do not have permission to view this report', 403));
    }

    // Increment view count
    report.viewCount += 1;
    await report.save({ validateBeforeSave: false });

    // Filter internal notes for non-privileged users
    let responseReport = report.toObject();
    if (!isPrivileged) {
      delete responseReport.internalNotes;
      delete responseReport.submitterIp;
    }

    // Filter non-public comments for non-privileged users
    if (!isPrivileged) {
      responseReport.comments = responseReport.comments.filter((c) => c.isPublic);
    }

    res.status(200).json({
      success: true,
      data: {
        report: responseReport,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get report by tracking ID
 * GET /api/v1/reports/track/:reportId
 */
exports.trackReport = async (req, res, next) => {
  try {
    const report = await Report.findOne({ reportId: req.params.reportId })
      .select('reportId title incidentType severity status statusHistory createdAt verification.isVerified resolution');

    if (!report) {
      return next(new AppError('Report not found', 404));
    }

    res.status(200).json({
      success: true,
      data: {
        report: {
          reportId: report.reportId,
          title: report.title,
          incidentType: report.incidentType,
          severity: report.severity,
          status: report.status,
          statusHistory: report.statusHistory.map((h) => ({
            status: h.status,
            changedAt: h.changedAt,
          })),
          isVerified: report.verification.isVerified,
          isResolved: report.resolution.isResolved,
          createdAt: report.createdAt,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update report
 * PATCH /api/v1/reports/:id
 */
exports.updateReport = async (req, res, next) => {
  try {
    const report = await Report.findById(req.params.id);

    if (!report) {
      return next(new AppError('Report not found', 404));
    }

    // Only owner can update, and only if status is draft or submitted
    const isOwner = report.reporter?.toString() === req.user._id.toString();
    if (!isOwner) {
      return next(new AppError('You can only update your own reports', 403));
    }

    if (!['draft', 'submitted'].includes(report.status)) {
      return next(new AppError('Cannot update report after it has been reviewed', 400));
    }

    const allowedUpdates = [
      'title',
      'description',
      'incidentDate',
      'incidentTime',
      'severity',
      'affectedPlatform',
      'affectedService',
      'tags',
    ];

    allowedUpdates.forEach((field) => {
      if (req.body[field] !== undefined) {
        report[field] = req.body[field];
      }
    });

    await report.save();

    await AuditLog.log({
      action: 'report_updated',
      performedBy: req.user._id,
      targetReport: report._id,
      details: { updatedFields: Object.keys(req.body) },
      ipAddress: req.ip,
    });

    res.status(200).json({
      success: true,
      message: 'Report updated successfully',
      data: {
        report,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update report status (Analyst/Moderator/Admin)
 * PATCH /api/v1/reports/:id/status
 */
exports.updateReportStatus = async (req, res, next) => {
  try {
    const { status, notes } = req.body;
    const report = await Report.findById(req.params.id).populate('reporter', 'email firstName');

    if (!report) {
      return next(new AppError('Report not found', 404));
    }

    const oldStatus = report.status;
    report.updateStatus(status, req.user._id, notes);

    // Handle specific status changes
    if (status === 'verified') {
      report.verification = {
        isVerified: true,
        verifiedBy: req.user._id,
        verifiedAt: new Date(),
        verificationNotes: notes,
      };

      // Update reporter reputation
      if (report.reporter) {
        const reporter = await User.findById(report.reporter._id);
        if (reporter) {
          reporter.updateReputation('verified');
          await reporter.save({ validateBeforeSave: false });
        }
      }
    }

    if (status === 'rejected') {
      // Update reporter reputation
      if (report.reporter) {
        const reporter = await User.findById(report.reporter._id);
        if (reporter) {
          reporter.updateReputation('rejected');
          await reporter.save({ validateBeforeSave: false });
        }
      }
    }

    if (status === 'resolved') {
      report.resolution = {
        isResolved: true,
        resolvedAt: new Date(),
        resolvedBy: req.user._id,
        resolutionSummary: notes,
      };
    }

    await report.save();

    // Send status update email
    const emailTo = report.reporter?.email || report.reporterEmail;
    if (emailTo) {
      try {
        await sendReportStatusUpdateEmail(
          emailTo,
          report.reporter?.firstName || null,
          report.reportId,
          oldStatus,
          status
        );
      } catch (emailError) {
        console.error('Failed to send status update email:', emailError);
      }
    }

    // Create notification
    if (report.reporter) {
      await Notification.createNotification({
        recipient: report.reporter._id || report.reporter,
        type: 'report_status_update',
        title: 'Report Status Updated',
        message: `Your report ${report.reportId} status has been updated to ${status}`,
        data: { reportId: report.reportId, status },
        link: `/reports/${report.reportId}`,
      });
    }

    await AuditLog.log({
      action: 'report_status_change',
      performedBy: req.user._id,
      targetReport: report._id,
      details: { oldStatus, newStatus: status, notes },
      ipAddress: req.ip,
    });

    res.status(200).json({
      success: true,
      message: 'Report status updated',
      data: {
        report: {
          id: report._id,
          reportId: report.reportId,
          status: report.status,
          statusHistory: report.statusHistory,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Assign report to analyst
 * PATCH /api/v1/reports/:id/assign
 */
exports.assignReport = async (req, res, next) => {
  try {
    const { assigneeId } = req.body;
    const report = await Report.findById(req.params.id);

    if (!report) {
      return next(new AppError('Report not found', 404));
    }

    // Verify assignee exists and has appropriate role
    const assignee = await User.findById(assigneeId);
    if (!assignee || !['analyst', 'moderator', 'admin'].includes(assignee.role)) {
      return next(new AppError('Invalid assignee', 400));
    }

    report.assignedTo = assigneeId;
    report.assignedAt = new Date();

    if (report.status === 'submitted') {
      report.updateStatus('under_review', req.user._id, 'Assigned for review');
    }

    await report.save();

    // Notify assignee
    await Notification.createNotification({
      recipient: assigneeId,
      type: 'report_assigned',
      title: 'New Report Assigned',
      message: `Report ${report.reportId} has been assigned to you`,
      data: { reportId: report.reportId },
      link: `/reports/${report._id}`,
    });

    await AuditLog.log({
      action: 'report_assigned',
      performedBy: req.user._id,
      targetReport: report._id,
      details: { assignedTo: assigneeId },
      ipAddress: req.ip,
    });

    res.status(200).json({
      success: true,
      message: 'Report assigned successfully',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Escalate report
 * PATCH /api/v1/reports/:id/escalate
 */
exports.escalateReport = async (req, res, next) => {
  try {
    const { escalateTo, reason } = req.body;
    const report = await Report.findById(req.params.id);

    if (!report) {
      return next(new AppError('Report not found', 404));
    }

    report.escalation = {
      isEscalated: true,
      escalatedTo: escalateTo,
      escalatedAt: new Date(),
      escalatedBy: req.user._id,
      escalationReason: reason,
    };

    report.updateStatus('escalated', req.user._id, `Escalated to ${escalateTo}: ${reason}`);
    report.priority = 'urgent';

    await report.save();

    await AuditLog.log({
      action: 'report_escalated',
      performedBy: req.user._id,
      targetReport: report._id,
      details: { escalatedTo: escalateTo, reason },
      ipAddress: req.ip,
    });

    res.status(200).json({
      success: true,
      message: 'Report escalated successfully',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Add comment to report
 * POST /api/v1/reports/:id/comments
 */
exports.addComment = async (req, res, next) => {
  try {
    const { comment, isPublic } = req.body;
    const report = await Report.findById(req.params.id);

    if (!report) {
      return next(new AppError('Report not found', 404));
    }

    report.comments.push({
      comment,
      createdBy: req.user._id,
      isPublic: isPublic !== false,
    });

    await report.save();

    // Notify report owner if comment is public
    if (isPublic !== false && report.reporter) {
      await Notification.createNotification({
        recipient: report.reporter,
        type: 'report_comment',
        title: 'New Comment on Your Report',
        message: `Someone commented on your report ${report.reportId}`,
        data: { reportId: report.reportId },
        link: `/reports/${report._id}`,
      });
    }

    res.status(201).json({
      success: true,
      message: 'Comment added successfully',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Add internal note (Analyst/Moderator/Admin only)
 * POST /api/v1/reports/:id/notes
 */
exports.addInternalNote = async (req, res, next) => {
  try {
    const { note } = req.body;
    const report = await Report.findById(req.params.id);

    if (!report) {
      return next(new AppError('Report not found', 404));
    }

    report.internalNotes.push({
      note,
      createdBy: req.user._id,
    });

    await report.save();

    res.status(201).json({
      success: true,
      message: 'Internal note added',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Save draft
 * POST /api/v1/reports/draft
 */
exports.saveDraft = async (req, res, next) => {
  try {
    const draftData = {
      ...req.body,
      reporter: req.user?._id,
      isDraft: true,
      status: 'draft',
      lastAutoSave: new Date(),
      dataProcessingConsent: true, // Required for drafts too
    };

    let report;
    if (req.body.draftId) {
      report = await Report.findByIdAndUpdate(
        req.body.draftId,
        { ...draftData, lastAutoSave: new Date() },
        { new: true }
      );
    } else {
      report = await Report.create(draftData);
    }

    res.status(200).json({
      success: true,
      message: 'Draft saved',
      data: {
        draftId: report._id,
        lastAutoSave: report.lastAutoSave,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get user's drafts
 * GET /api/v1/reports/drafts
 */
exports.getDrafts = async (req, res, next) => {
  try {
    const drafts = await Report.find({
      reporter: req.user._id,
      isDraft: true,
    })
      .sort({ lastAutoSave: -1 })
      .select('title incidentType lastAutoSave createdAt');

    res.status(200).json({
      success: true,
      data: {
        drafts,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete report
 * DELETE /api/v1/reports/:id
 */
exports.deleteReport = async (req, res, next) => {
  try {
    const report = await Report.findById(req.params.id);

    if (!report) {
      return next(new AppError('Report not found', 404));
    }

    // Only owner can delete drafts, admins can delete any
    const isOwner = report.reporter?.toString() === req.user._id.toString();
    const isAdmin = req.user.role === 'admin';

    if (!isOwner && !isAdmin) {
      return next(new AppError('You do not have permission to delete this report', 403));
    }

    if (!isAdmin && report.status !== 'draft') {
      return next(new AppError('Only draft reports can be deleted', 400));
    }

    await Report.findByIdAndDelete(req.params.id);

    await AuditLog.log({
      action: 'report_deleted',
      performedBy: req.user._id,
      details: { reportId: report.reportId },
      ipAddress: req.ip,
    });

    res.status(200).json({
      success: true,
      message: 'Report deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get report statistics
 * GET /api/v1/reports/stats
 */
exports.getReportStats = async (req, res, next) => {
  try {
    const stats = await Report.aggregate([
      {
        $facet: {
          byStatus: [
            { $group: { _id: '$status', count: { $sum: 1 } } },
          ],
          byType: [
            { $group: { _id: '$incidentType', count: { $sum: 1 } } },
          ],
          bySeverity: [
            { $group: { _id: '$severity', count: { $sum: 1 } } },
          ],
          byMonth: [
            {
              $group: {
                _id: {
                  year: { $year: '$createdAt' },
                  month: { $month: '$createdAt' },
                },
                count: { $sum: 1 },
              },
            },
            { $sort: { '_id.year': -1, '_id.month': -1 } },
            { $limit: 12 },
          ],
          total: [
            { $count: 'count' },
          ],
          recentWeek: [
            {
              $match: {
                createdAt: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) },
              },
            },
            { $count: 'count' },
          ],
        },
      },
    ]);

    res.status(200).json({
      success: true,
      data: {
        stats: stats[0],
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get incident type categories
 * GET /api/v1/reports/categories
 */
exports.getCategories = async (req, res, next) => {
  try {
    const categories = Report.getIncidentCategories();

    res.status(200).json({
      success: true,
      data: {
        categories,
      },
    });
  } catch (error) {
    next(error);
  }
};
