import '../repositories/auth_repository.dart';

class Setup2FAUseCase {
  final AuthRepository repository;

  Setup2FAUseCase(this.repository);

  Future<TwoFactorSetupResult> call() async {
    return await repository.setup2FA();
  }
}
