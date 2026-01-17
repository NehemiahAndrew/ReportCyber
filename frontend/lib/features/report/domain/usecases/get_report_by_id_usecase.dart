import '../entities/report.dart';
import '../repositories/report_repository.dart';

class GetReportByIdUseCase {
  final ReportRepository repository;

  GetReportByIdUseCase(this.repository);

  Future<Report?> call(String id) async {
    return await repository.getReportById(id);
  }
}
