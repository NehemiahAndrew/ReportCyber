import 'dart:io';

import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_data_source.dart';
import '../datasources/report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;
  final ReportLocalDataSource localDataSource;

  ReportRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<ReportListResult> getReports({
    int page = 1,
    int limit = 10,
    ReportType? type,
    ReportStatus? status,
    SeverityLevel? severity,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final result = await remoteDataSource.getReports(
        page: page,
        limit: limit,
        type: type,
        status: status,
        severity: severity,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      // Cache first page of reports
      if (page == 1) {
        await localDataSource.cacheReports(result.reports);
      }

      return result;
    } catch (e) {
      // Try to return cached reports on error
      if (page == 1) {
        final cachedReports = await localDataSource.getCachedReports();
        if (cachedReports.isNotEmpty) {
          return ReportListResult(
            reports: cachedReports,
            totalCount: cachedReports.length,
            currentPage: 1,
            totalPages: 1,
            hasNextPage: false,
            hasPrevPage: false,
          );
        }
      }
      rethrow;
    }
  }

  @override
  Future<Report?> getReportById(String id) async {
    return await remoteDataSource.getReportById(id);
  }

  @override
  Future<ReportListResult> getMyReports({
    int page = 1,
    int limit = 10,
    ReportStatus? status,
  }) async {
    return await remoteDataSource.getMyReports(
      page: page,
      limit: limit,
      status: status,
    );
  }

  @override
  Future<List<Report>> getDrafts() async {
    return await remoteDataSource.getDrafts();
  }

  @override
  Future<ReportResult> createReport(CreateReportParams params) async {
    try {
      final report = await remoteDataSource.createReport(params);

      // Clear local draft after successful creation
      if (!params.saveAsDraft) {
        await localDataSource.clearDraft();
      }

      return ReportResult(
        success: true,
        report: report,
        message: params.saveAsDraft
            ? 'Report saved as draft'
            : 'Report created successfully',
      );
    } catch (e) {
      return ReportResult(
        success: false,
        error: e.toString(),
        message: 'Failed to create report',
      );
    }
  }

  @override
  Future<ReportResult> updateReport(
    String id,
    UpdateReportParams params,
  ) async {
    try {
      final report = await remoteDataSource.updateReport(id, params);
      return ReportResult(
        success: true,
        report: report,
        message: 'Report updated successfully',
      );
    } catch (e) {
      return ReportResult(
        success: false,
        error: e.toString(),
        message: 'Failed to update report',
      );
    }
  }

  @override
  Future<ReportResult> submitReport(String id) async {
    try {
      final report = await remoteDataSource.submitReport(id);
      await localDataSource.clearDraft();
      return ReportResult(
        success: true,
        report: report,
        message: 'Report submitted successfully',
      );
    } catch (e) {
      return ReportResult(
        success: false,
        error: e.toString(),
        message: 'Failed to submit report',
      );
    }
  }

  @override
  Future<void> deleteReport(String id) async {
    await remoteDataSource.deleteReport(id);
  }

  @override
  Future<Evidence> uploadEvidence(String reportId, File file) async {
    return await remoteDataSource.uploadEvidence(reportId, file);
  }

  @override
  Future<void> deleteEvidence(String reportId, String evidenceId) async {
    await remoteDataSource.deleteEvidence(reportId, evidenceId);
  }

  @override
  Future<void> upvoteReport(String id) async {
    await remoteDataSource.upvoteReport(id);
  }

  @override
  Future<void> downvoteReport(String id) async {
    await remoteDataSource.downvoteReport(id);
  }

  @override
  Future<void> saveDraftLocally(Report report) async {
    await localDataSource.cacheDraft(report);
  }

  @override
  Future<Report?> getLocalDraft() async {
    return await localDataSource.getCachedDraft();
  }

  @override
  Future<void> clearLocalDraft() async {
    await localDataSource.clearDraft();
  }
}
