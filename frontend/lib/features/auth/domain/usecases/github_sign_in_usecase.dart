import '../repositories/auth_repository.dart';

class GitHubSignInUseCase {
  final AuthRepository repository;

  GitHubSignInUseCase(this.repository);

  Future<AuthResult> call() async {
    return await repository.githubSignIn();
  }
}
