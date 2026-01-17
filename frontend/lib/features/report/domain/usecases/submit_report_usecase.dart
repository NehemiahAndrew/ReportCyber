import '../repositories/report_repository.dart';

class SubmitReportUseCase {
  final ReportRepository repository;

  SubmitReportUseCase(this.repository);

  Future<ReportResult> call(String reportId) async {
    return await repository.submitReport(reportId);
  }
}
