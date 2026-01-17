import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/verification_result.dart';

abstract class VerificationRepository {
  Future<Either<Failure, VerificationResultEntity>> verifyEvidence({
    required Uint8List fileBytes,
    required String fileName,
    String? reportId,
  });

  Future<Either<Failure, List<VerificationHistoryItem>>>
      getVerificationHistory({
    int limit = 20,
    int page = 1,
  });

  Future<Either<Failure, ComparisonResult>> compareEvidence(String fileHash);
}
