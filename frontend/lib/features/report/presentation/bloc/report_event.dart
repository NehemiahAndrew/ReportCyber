import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

/// Load reports list
class LoadReports extends ReportEvent {
  final int page;
  final int limit;
  final ReportType? type;
  final ReportStatus? status;
  final SeverityLevel? severity;
  final String? search;
  final bool refresh;

  const LoadReports({
    this.page = 1,
    this.limit = 10,
    this.type,
    this.status,
    this.severity,
    this.search,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    type,
    status,
    severity,
    search,
    refresh,
  ];
}

/// Load user's own reports
class LoadMyReports extends ReportEvent {
  final int page;
  final ReportStatus? status;

  const LoadMyReports({this.page = 1, this.status});

  @override
  List<Object?> get props => [page, status];
}

/// Load single report details
class LoadReportDetails extends ReportEvent {
  final String reportId;

  const LoadReportDetails({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}

/// Create new report
class CreateReport extends ReportEvent {
  final CreateReportParams params;

  const CreateReport({required this.params});

  @override
  List<Object?> get props => [params];
}

/// Update existing report
class UpdateReport extends ReportEvent {
  final String reportId;
  final UpdateReportParams params;

  const UpdateReport({required this.reportId, required this.params});

  @override
  List<Object?> get props => [reportId, params];
}

/// Submit draft report
class SubmitReport extends ReportEvent {
  final String reportId;

  const SubmitReport({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}

/// Delete report
class DeleteReport extends ReportEvent {
  final String reportId;

  const DeleteReport({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}

/// Upload evidence
class UploadEvidence extends ReportEvent {
  final String reportId;
  final File file;

  const UploadEvidence({required this.reportId, required this.file});

  @override
  List<Object?> get props => [reportId, file.path];
}

/// Delete evidence
class DeleteEvidence extends ReportEvent {
  final String reportId;
  final String evidenceId;

  const DeleteEvidence({required this.reportId, required this.evidenceId});

  @override
  List<Object?> get props => [reportId, evidenceId];
}

/// Upvote report
class UpvoteReport extends ReportEvent {
  final String reportId;

  const UpvoteReport({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}

/// Downvote report
class DownvoteReport extends ReportEvent {
  final String reportId;

  const DownvoteReport({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}

/// Save draft locally
class SaveDraftLocally extends ReportEvent {
  final Report report;

  const SaveDraftLocally({required this.report});

  @override
  List<Object?> get props => [report];
}

/// Load local draft
class LoadLocalDraft extends ReportEvent {
  const LoadLocalDraft();
}

/// Clear form/error state
class ClearReportState extends ReportEvent {
  const ClearReportState();
}
