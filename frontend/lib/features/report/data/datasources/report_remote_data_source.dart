import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';

abstract class ReportRemoteDataSource {
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

  Future<Report> getReportById(String id);

  Future<ReportListResult> getMyReports({
    int page = 1,
    int limit = 10,
    ReportStatus? status,
  });

  Future<List<Report>> getDrafts();

  Future<Report> createReport(CreateReportParams params);

  Future<Report> updateReport(String id, UpdateReportParams params);

  Future<Report> submitReport(String id);

  Future<void> deleteReport(String id);

  Future<Evidence> uploadEvidence(String reportId, File file);

  Future<void> deleteEvidence(String reportId, String evidenceId);

  Future<void> upvoteReport(String id);

  Future<void> downvoteReport(String id);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient apiClient;

  ReportRemoteDataSourceImpl({required this.apiClient});

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
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};

    if (type != null) queryParams['type'] = type.name;
    if (status != null) queryParams['status'] = status.name;
    if (severity != null) queryParams['severity'] = severity.name;
    if (search != null) queryParams['search'] = search;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

    final response = await apiClient.get(
      '/reports',
      queryParameters: queryParams,
    );

    return ReportListResult.fromJson(response.data);
  }

  @override
  Future<Report> getReportById(String id) async {
    final response = await apiClient.get('/reports/$id');
    return Report.fromJson(response.data['report']);
  }

  @override
  Future<ReportListResult> getMyReports({
    int page = 1,
    int limit = 10,
    ReportStatus? status,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};

    if (status != null) queryParams['status'] = status.name;

    final response = await apiClient.get(
      '/reports/my-reports',
      queryParameters: queryParams,
    );

    return ReportListResult.fromJson(response.data);
  }

  @override
  Future<List<Report>> getDrafts() async {
    final response = await apiClient.get('/reports/drafts');
    return (response.data['reports'] as List)
        .map((r) => Report.fromJson(r))
        .toList();
  }

  @override
  Future<Report> createReport(CreateReportParams params) async {
    final response = await apiClient.post('/reports', data: params.toJson());
    return Report.fromJson(response.data['report']);
  }

  @override
  Future<Report> updateReport(String id, UpdateReportParams params) async {
    final response = await apiClient.put('/reports/$id', data: params.toJson());
    return Report.fromJson(response.data['report']);
  }

  @override
  Future<Report> submitReport(String id) async {
    final response = await apiClient.post('/reports/$id/submit');
    return Report.fromJson(response.data['report']);
  }

  @override
  Future<void> deleteReport(String id) async {
    await apiClient.delete('/reports/$id');
  }

  @override
  Future<Evidence> uploadEvidence(String reportId, File file) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await apiClient.post(
      '/reports/$reportId/evidence',
      data: formData,
    );

    return Evidence.fromJson(response.data['evidence']);
  }

  @override
  Future<void> deleteEvidence(String reportId, String evidenceId) async {
    await apiClient.delete('/reports/$reportId/evidence/$evidenceId');
  }

  @override
  Future<void> upvoteReport(String id) async {
    await apiClient.post('/reports/$id/upvote');
  }

  @override
  Future<void> downvoteReport(String id) async {
    await apiClient.post('/reports/$id/downvote');
  }
}
