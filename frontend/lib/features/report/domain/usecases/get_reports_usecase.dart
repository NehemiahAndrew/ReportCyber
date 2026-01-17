import '../entities/report.dart';
import '../repositories/report_repository.dart';

class GetReportsUseCase {
  final ReportRepository repository;

  GetReportsUseCase(this.repository);

  Future<ReportListResult> call({
    int page = 1,
    int limit = 10,
    ReportType? type,
    ReportStatus? status,
    SeverityLevel? severity,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    return await repository.getReports(
      page: page,
      limit: limit,
      type: type,
      status: status,
      severity: severity,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }
}
