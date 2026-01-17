import 'package:equatable/equatable.dart';

import '../../domain/entities/report.dart';

enum ReportStateStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  updating,
  updated,
  submitting,
  submitted,
  deleting,
  deleted,
  uploading,
  error,
}

class ReportState extends Equatable {
  final ReportStateStatus status;
  final List<Report> reports;
  final Report? selectedReport;
  final Report? draftReport;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? successMessage;
  final double uploadProgress;

  const ReportState({
    this.status = ReportStateStatus.initial,
    this.reports = const [],
    this.selectedReport,
    this.draftReport,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasNextPage = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.successMessage,
    this.uploadProgress = 0,
  });

  factory ReportState.initial() => const ReportState();

  ReportState loading() => copyWith(
    status: ReportStateStatus.loading,
    errorMessage: null,
    successMessage: null,
  );

  ReportState loadingMore() =>
      copyWith(isLoadingMore: true, errorMessage: null);

  ReportState loaded({
    required List<Report> reports,
    required int currentPage,
    required int totalPages,
    required int totalCount,
    required bool hasNextPage,
    bool append = false,
  }) => copyWith(
    status: ReportStateStatus.loaded,
    reports: append ? [...this.reports, ...reports] : reports,
    currentPage: currentPage,
    totalPages: totalPages,
    totalCount: totalCount,
    hasNextPage: hasNextPage,
    isLoadingMore: false,
    errorMessage: null,
  );

  ReportState withSelectedReport(Report report) => copyWith(
    selectedReport: report,
    status: ReportStateStatus.loaded,
    errorMessage: null,
  );

  ReportState creating() =>
      copyWith(status: ReportStateStatus.creating, errorMessage: null);

  ReportState created({required Report report, String? message}) => copyWith(
    status: ReportStateStatus.created,
    selectedReport: report,
    successMessage: message ?? 'Report created successfully',
    errorMessage: null,
  );

  ReportState submitting() =>
      copyWith(status: ReportStateStatus.submitting, errorMessage: null);

  ReportState submitted({required Report report, String? message}) => copyWith(
    status: ReportStateStatus.submitted,
    selectedReport: report,
    successMessage: message ?? 'Report submitted successfully',
    errorMessage: null,
  );

  ReportState uploading({double progress = 0}) =>
      copyWith(status: ReportStateStatus.uploading, uploadProgress: progress);

  ReportState withDraft(Report draft) => copyWith(draftReport: draft);

  ReportState error({required String message}) => copyWith(
    status: ReportStateStatus.error,
    errorMessage: message,
    successMessage: null,
    isLoadingMore: false,
  );

  ReportState clearMessages() =>
      copyWith(errorMessage: null, successMessage: null);

  ReportState copyWith({
    ReportStateStatus? status,
    List<Report>? reports,
    Report? selectedReport,
    Report? draftReport,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasNextPage,
    bool? isLoadingMore,
    String? errorMessage,
    String? successMessage,
    double? uploadProgress,
  }) {
    return ReportState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      selectedReport: selectedReport ?? this.selectedReport,
      draftReport: draftReport ?? this.draftReport,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      successMessage: successMessage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  @override
  List<Object?> get props => [
    status,
    reports,
    selectedReport,
    draftReport,
    currentPage,
    totalPages,
    totalCount,
    hasNextPage,
    isLoadingMore,
    errorMessage,
    successMessage,
    uploadProgress,
  ];
}
