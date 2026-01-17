import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/verification_result.dart';
import '../repositories/verification_repository.dart';

class VerifyEvidenceUseCase
    implements UseCase<VerificationResultEntity, VerifyEvidenceParams> {
  final VerificationRepository repository;

  VerifyEvidenceUseCase(this.repository);

  @override
  Future<Either<Failure, VerificationResultEntity>> call(
      VerifyEvidenceParams params) async {
    return await repository.verifyEvidence(
      fileBytes: params.fileBytes,
      fileName: params.fileName,
      reportId: params.reportId,
    );
  }
}

class VerifyEvidenceParams {
  final Uint8List fileBytes;
  final String fileName;
  final String? reportId;

  VerifyEvidenceParams({
    required this.fileBytes,
    required this.fileName,
    this.reportId,
  });
}
