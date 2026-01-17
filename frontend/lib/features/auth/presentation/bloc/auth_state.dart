import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  requires2FA,
  registrationSuccess,
  passwordResetSent,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? accessToken;
  final String? refreshToken;
  final String? tempUserId;
  final String? errorMessage;
  final String? successMessage;
  final TwoFactorSetupData? twoFactorSetup;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.tempUserId,
    this.errorMessage,
    this.successMessage,
    this.twoFactorSetup,
  });

  /// Initial state
  factory AuthState.initial() => const AuthState();

  /// Loading state
  AuthState loading() => copyWith(
    status: AuthStatus.loading,
    errorMessage: null,
    successMessage: null,
  );

  /// Authenticated state
  AuthState authenticated({
    required User user,
    String? accessToken,
    String? refreshToken,
  }) => copyWith(
    status: AuthStatus.authenticated,
    user: user,
    accessToken: accessToken,
    refreshToken: refreshToken,
    errorMessage: null,
    tempUserId: null,
  );

  /// Unauthenticated state
  AuthState unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  /// Requires 2FA state
  AuthState requires2FA({required String tempUserId}) => copyWith(
    status: AuthStatus.requires2FA,
    tempUserId: tempUserId,
    errorMessage: null,
  );

  /// Registration success state
  AuthState registrationSuccess({String? message}) => copyWith(
    status: AuthStatus.registrationSuccess,
    successMessage:
        message ??
        'Registration successful. Please check your email to verify your account.',
    errorMessage: null,
  );

  /// Password reset sent state
  AuthState passwordResetSent({String? message}) => copyWith(
    status: AuthStatus.passwordResetSent,
    successMessage: message ?? 'Password reset link sent to your email.',
    errorMessage: null,
  );

  /// Error state
  AuthState error({required String message}) => copyWith(
    status: AuthStatus.error,
    errorMessage: message,
    successMessage: null,
  );

  /// 2FA setup state
  AuthState with2FASetup({required TwoFactorSetupData setup}) => copyWith(
    twoFactorSetup: setup,
    successMessage:
        '2FA setup initiated. Scan the QR code with your authenticator app.',
  );

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? accessToken,
    String? refreshToken,
    String? tempUserId,
    String? errorMessage,
    String? successMessage,
    TwoFactorSetupData? twoFactorSetup,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tempUserId: tempUserId ?? this.tempUserId,
      errorMessage: errorMessage,
      successMessage: successMessage,
      twoFactorSetup: twoFactorSetup ?? this.twoFactorSetup,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    accessToken,
    refreshToken,
    tempUserId,
    errorMessage,
    successMessage,
    twoFactorSetup,
  ];
}

/// 2FA setup data
class TwoFactorSetupData extends Equatable {
  final String secret;
  final String qrCodeUrl;
  final List<String>? backupCodes;

  const TwoFactorSetupData({
    required this.secret,
    required this.qrCodeUrl,
    this.backupCodes,
  });

  @override
  List<Object?> get props => [secret, qrCodeUrl, backupCodes];
}
