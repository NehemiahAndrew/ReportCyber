import 'dart:io';

import '../entities/report.dart';

/// Report repository interface
abstract class ReportRepository {
  /// Get all reports with optional filters
  Future<ReportListResult> getReports({
    int page = 1,
    int limit = 10,
    ReportType? type,
    ReportStatus? status,
    SeverityLevel? severity,
    String? search,
    String? sortBy,
    String? sortOrder,
  });

  /// Get a single report by ID
  Future<Report?> getReportById(String id);

  /// Get reports by the current user
  Future<ReportListResult> getMyReports({
    int page = 1,
    int limit = 10,
    ReportStatus? status,
  });

  /// Get draft reports
  Future<List<Report>> getDrafts();

  /// Create a new report
  Future<ReportResult> createReport(CreateReportParams params);

  /// Update an existing report
  Future<ReportResult> updateReport(String id, UpdateReportParams params);

  /// Submit a draft report
  Future<ReportResult> submitReport(String id);

  /// Delete a report
  Future<void> deleteReport(String id);

  /// Upload evidence for a report
  Future<Evidence> uploadEvidence(String reportId, File file);

  /// Delete evidence from a report
  Future<void> deleteEvidence(String reportId, String evidenceId);

  /// Upvote a report
  Future<void> upvoteReport(String id);

  /// Downvote a report
  Future<void> downvoteReport(String id);

  /// Save report as draft locally
  Future<void> saveDraftLocally(Report report);

  /// Get locally saved draft
  Future<Report?> getLocalDraft();

  /// Clear local draft
  Future<void> clearLocalDraft();
}

/// Result for report list operations
class ReportListResult {
  final List<Report> reports;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  ReportListResult({
    required this.reports,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory ReportListResult.fromJson(Map<String, dynamic> json) {
    return ReportListResult(
      reports:
          (json['reports'] as List?)?.map((r) => Report.fromJson(r)).toList() ??
          [],
      totalCount: json['pagination']?['totalCount'] ?? 0,
      currentPage: json['pagination']?['currentPage'] ?? 1,
      totalPages: json['pagination']?['totalPages'] ?? 1,
      hasNextPage: json['pagination']?['hasNextPage'] ?? false,
      hasPrevPage: json['pagination']?['hasPrevPage'] ?? false,
    );
  }
}

/// Result for single report operations
class ReportResult {
  final bool success;
  final Report? report;
  final String? message;
  final String? error;

  ReportResult({required this.success, this.report, this.message, this.error});
}

/// Parameters for creating a report
class CreateReportParams {
  final ReportType type;
  final String title;
  final String description;
  final SeverityLevel severity;
  final bool isAnonymous;
  final DateTime? incidentDate;
  final ReportLocation? location;
  final String? locationString;
  final List<String> affectedSystems;
  final String? attackerInfo;
  final List<String> suspiciousUrls;
  final List<String> suspiciousEmails;
  final List<String> suspiciousIps;
  final double? financialLoss;
  final String? currency;
  final bool saveAsDraft;
  final List<dynamic>? evidenceFiles;

  CreateReportParams({
    required this.type,
    required this.title,
    required this.description,
    this.severity = SeverityLevel.medium,
    this.isAnonymous = false,
    this.incidentDate,
    this.location,
    this.locationString,
    this.affectedSystems = const [],
    this.attackerInfo,
    this.suspiciousUrls = const [],
    this.suspiciousEmails = const [],
    this.suspiciousIps = const [],
    this.financialLoss,
    this.currency,
    this.saveAsDraft = false,
    this.evidenceFiles,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'title': title,
    'description': description,
    'severity': severity.name,
    'isAnonymous': isAnonymous,
    'incidentDate': incidentDate?.toIso8601String(),
    'location':
        location?.toJson() ??
        (locationString != null ? {'address': locationString} : null),
    'affectedSystems': affectedSystems,
    'attackerInfo': attackerInfo,
    'suspiciousUrls': suspiciousUrls,
    'suspiciousEmails': suspiciousEmails,
    'suspiciousIps': suspiciousIps,
    'financialLoss': financialLoss,
    'currency': currency,
    'saveAsDraft': saveAsDraft,
  };
}

/// Parameters for updating a report
class UpdateReportParams {
  final ReportType? type;
  final String? title;
  final String? description;
  final SeverityLevel? severity;
  final DateTime? incidentDate;
  final ReportLocation? location;
  final List<String>? affectedSystems;
  final String? attackerInfo;
  final List<String>? suspiciousUrls;
  final List<String>? suspiciousEmails;
  final List<String>? suspiciousIps;
  final double? financialLoss;
  final String? currency;

  UpdateReportParams({
    this.type,
    this.title,
    this.description,
    this.severity,
    this.incidentDate,
    this.location,
    this.affectedSystems,
    this.attackerInfo,
    this.suspiciousUrls,
    this.suspiciousEmails,
    this.suspiciousIps,
    this.financialLoss,
    this.currency,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (type != null) data['type'] = type!.name;
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (severity != null) data['severity'] = severity!.name;
    if (incidentDate != null) {
      data['incidentDate'] = incidentDate!.toIso8601String();
    }
    if (location != null) data['location'] = location!.toJson();
    if (affectedSystems != null) data['affectedSystems'] = affectedSystems;
    if (attackerInfo != null) data['attackerInfo'] = attackerInfo;
    if (suspiciousUrls != null) data['suspiciousUrls'] = suspiciousUrls;
    if (suspiciousEmails != null) data['suspiciousEmails'] = suspiciousEmails;
    if (suspiciousIps != null) data['suspiciousIps'] = suspiciousIps;
    if (financialLoss != null) data['financialLoss'] = financialLoss;
    if (currency != null) data['currency'] = currency;
    return data;
  }
}
