import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthResult> call({
    required String email,
    required String password,
    String? totpCode,
  }) async {
    return await repository.login(
      email: email,
      password: password,
      totpCode: totpCode,
    );
  }
}
