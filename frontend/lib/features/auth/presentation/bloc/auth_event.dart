import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Login with email and password
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String? totpCode;

  const LoginRequested({
    required this.email,
    required this.password,
    this.totpCode,
  });

  @override
  List<Object?> get props => [email, password, totpCode];
}

/// Register new account
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String? lastName;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    this.lastName,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName];
}

/// Google sign in
class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

/// GitHub sign in
class GitHubSignInRequested extends AuthEvent {
  const GitHubSignInRequested();
}

/// Verify 2FA code
class Verify2FARequested extends AuthEvent {
  final String userId;
  final String totpCode;

  const Verify2FARequested({required this.userId, required this.totpCode});

  @override
  List<Object?> get props => [userId, totpCode];
}

/// Logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Check authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Forgot password
class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Reset password
class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;

  const ResetPasswordRequested({
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [token, newPassword];
}

/// Setup 2FA
class Setup2FARequested extends AuthEvent {
  const Setup2FARequested();
}

/// Disable 2FA
class Disable2FARequested extends AuthEvent {
  final String totpCode;

  const Disable2FARequested({required this.totpCode});

  @override
  List<Object?> get props => [totpCode];
}

/// Clear error state
class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}
