import '../entities/user.dart';

abstract class AuthRepository {
  Future<AuthResult> login({
    required String email,
    required String password,
    String? totpCode,
  });

  Future<AuthResult> register({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
  });

  Future<AuthResult> googleSignIn();

  Future<AuthResult> githubSignIn();

  Future<void> logout();

  Future<void> logoutAll();

  Future<User?> getCurrentUser();

  Future<bool> isAuthenticated();

  Future<void> verifyEmail(String token);

  Future<void> resendVerificationEmail(String email);

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({required String token, required String password});

  Future<TwoFactorSetupResult> setup2FA();

  Future<AuthResult> verify2FA(
      {required String userId, required String totpCode});

  Future<void> disable2FA({required String password, required String totpCode});

  Future<List<String>> generateBackupCodes(String password);

  Future<AuthResult> refreshToken();

  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? phone,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class AuthResult {
  final bool success;
  final User? user;
  final String? accessToken;
  final String? refreshToken;
  final bool requires2FA;
  final String? tempUserId;
  final String? message;
  final String? error;

  AuthResult({
    required this.success,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.requires2FA = false,
    this.tempUserId,
    this.message,
    this.error,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AuthResult(
      success: json['success'] ?? false,
      user: data?['user'] != null ? User.fromJson(data['user']) : null,
      accessToken: data?['tokens']?['accessToken'],
      refreshToken: data?['tokens']?['refreshToken'],
      requires2FA: json['requires2FA'] ?? false,
      tempUserId: json['tempUserId'],
      message: json['message'],
      error: json['error'],
    );
  }
}

class TwoFactorSetupResult {
  final bool success;
  final String secret;
  final String qrCode;
  final String? qrCodeUrl;
  final List<String>? backupCodes;
  final String? message;

  TwoFactorSetupResult({
    this.success = true,
    required this.secret,
    required this.qrCode,
    this.qrCodeUrl,
    this.backupCodes,
    this.message,
  });

  factory TwoFactorSetupResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return TwoFactorSetupResult(
      success: json['success'] ?? true,
      secret: data['secret'] ?? '',
      qrCode: data['qrCode'] ?? '',
      qrCodeUrl: data['qrCodeUrl'],
      backupCodes: data['backupCodes'] != null
          ? List<String>.from(data['backupCodes'])
          : null,
      message: json['message'],
    );
  }
}
