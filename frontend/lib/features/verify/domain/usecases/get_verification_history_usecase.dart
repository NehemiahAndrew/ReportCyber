import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/verification_result.dart';
import '../repositories/verification_repository.dart';

class GetVerificationHistoryUseCase
    implements UseCase<List<VerificationHistoryItem>, HistoryParams> {
  final VerificationRepository repository;

  GetVerificationHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<VerificationHistoryItem>>> call(
      HistoryParams params) async {
    return await repository.getVerificationHistory(
      limit: params.limit,
      page: params.page,
    );
  }
}

class HistoryParams {
  final int limit;
  final int page;

  HistoryParams({
    this.limit = 20,
    this.page = 1,
  });
}
