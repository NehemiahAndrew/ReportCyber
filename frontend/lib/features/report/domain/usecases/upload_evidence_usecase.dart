import 'dart:io';

import '../entities/report.dart';
import '../repositories/report_repository.dart';

class UploadEvidenceUseCase {
  final ReportRepository repository;

  UploadEvidenceUseCase(this.repository);

  Future<Evidence> call({required String reportId, required File file}) async {
    return await repository.uploadEvidence(reportId, file);
  }
}
