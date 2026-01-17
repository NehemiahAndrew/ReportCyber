import '../entities/report.dart';
import '../repositories/report_repository.dart';

class GetMyReportsUseCase {
  final ReportRepository repository;

  GetMyReportsUseCase(this.repository);

  Future<ReportListResult> call({
    int page = 1,
    int limit = 10,
    ReportStatus? status,
  }) async {
    return await repository.getMyReports(
      page: page,
      limit: limit,
      status: status,
    );
  }
}
