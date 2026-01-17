import '../repositories/report_repository.dart';

class CreateReportUseCase {
  final ReportRepository repository;

  CreateReportUseCase(this.repository);

  Future<ReportResult> call(CreateReportParams params) async {
    return await repository.createReport(params);
  }
}
