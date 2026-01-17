import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/verification_result.dart';
import '../repositories/verification_repository.dart';

class CompareEvidenceUseCase implements UseCase<ComparisonResult, String> {
  final VerificationRepository repository;

  CompareEvidenceUseCase(this.repository);

  @override
  Future<Either<Failure, ComparisonResult>> call(String fileHash) async {
    return await repository.compareEvidence(fileHash);
  }
}
