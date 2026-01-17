import '../repositories/auth_repository.dart';

class Verify2FAUseCase {
  final AuthRepository repository;

  Verify2FAUseCase(this.repository);

  Future<AuthResult> call({
    required String userId,
    required String totpCode,
  }) async {
    return await repository.verify2FA(userId: userId, totpCode: totpCode);
  }
}
