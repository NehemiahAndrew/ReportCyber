import '../../domain/entities/user.dart';

/// Data source for remote auth operations
abstract class AuthRemoteDataSource {
  /// Login with email and password
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    String? totpCode,
  });

  /// Register a new user
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
  });

  /// Verify email with token
  Future<void> verifyEmail({required String token});

  /// Request password reset
  Future<void> forgotPassword({required String email});

  /// Reset password with token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Refresh access token
  Future<AuthResponseModel> refreshToken({required String refreshToken});

  /// Google OAuth sign in
  Future<AuthResponseModel> googleSignIn({required String idToken});

  /// GitHub OAuth sign in
  Future<AuthResponseModel> githubSignIn({required String code});

  /// Setup two-factor authentication
  Future<TwoFactorSetupModel> setup2FA({required String accessToken});

  /// Verify 2FA code
  Future<AuthResponseModel> verify2FA({
    required String userId,
    required String totpCode,
  });

  /// Disable 2FA
  Future<void> disable2FA({
    required String accessToken,
    required String totpCode,
  });

  /// Logout
  Future<void> logout({required String refreshToken});

  /// Logout from all devices
  Future<void> logoutAll({required String accessToken});

  /// Get current user profile
  Future<UserModel> getCurrentUser({required String accessToken});

  /// Update user profile
  Future<UserModel> updateProfile({
    required String accessToken,
    String? firstName,
    String? lastName,
    String? bio,
    String? phone,
  });

  /// Change password
  Future<void> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  });

  /// Generate backup codes
  Future<List<String>> generateBackupCodes({
    required String accessToken,
    required String password,
  });

  /// Resend verification email
  Future<void> resendVerificationEmail({required String email});
}

/// User data model
class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String role;
  final String? avatar;
  final String? bio;
  final String? phone;
  final bool isEmailVerified;
  final bool twoFactorEnabled;
  final int trustScore;
  final int reportCount;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    required this.role,
    this.avatar,
    this.bio,
    this.phone,
    required this.isEmailVerified,
    required this.twoFactorEnabled,
    required this.trustScore,
    required this.reportCount,
    this.lastLoginAt,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'] ?? 'user',
      avatar: json['avatar'],
      bio: json['bio'],
      phone: json['phoneNumber'] ?? json['phone'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      trustScore: json['trustScore'] ?? json['reputation']?['score'] ?? 50,
      reportCount:
          json['reportCount'] ?? json['reputation']?['totalReports'] ?? 0,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'avatar': avatar,
        'bio': bio,
        'phone': phone,
        'isEmailVerified': isEmailVerified,
        'twoFactorEnabled': twoFactorEnabled,
        'trustScore': trustScore,
        'reportCount': reportCount,
        'lastLoginAt': lastLoginAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
      };

  User toEntity() => User(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: role,
        avatar: avatar,
        bio: bio,
        phone: phone,
        isEmailVerified: isEmailVerified,
        twoFactorEnabled: twoFactorEnabled,
        reputation: Reputation(
          score: trustScore,
          totalReports: reportCount,
          verifiedReports: 0,
          rejectedReports: 0,
          level: 'newcomer',
        ),
        notifications: NotificationPreferences(
          email: const EmailNotifications(
            reportUpdates: true,
            securityAlerts: true,
            newsletter: false,
            marketing: false,
          ),
          sms: const SmsNotifications(
            enabled: false,
            reportUpdates: false,
            securityAlerts: true,
          ),
          inApp: const InAppNotifications(
            reportUpdates: true,
            securityAlerts: true,
            communityUpdates: true,
          ),
        ),
        lastLoginAt: lastLoginAt,
        createdAt: createdAt,
      );
}

/// Auth response model with tokens and user
class AuthResponseModel {
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;
  final bool requires2FA;
  final String? tempUserId;
  final String? message;

  AuthResponseModel({
    this.accessToken,
    this.refreshToken,
    this.user,
    this.requires2FA = false,
    this.tempUserId,
    this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      requires2FA: json['requires2FA'] ?? false,
      tempUserId: json['userId'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'user': user?.toJson(),
        'requires2FA': requires2FA,
        'userId': tempUserId,
        'message': message,
      };
}

/// 2FA setup response model
class TwoFactorSetupModel {
  final String secret;
  final String qrCode;
  final String? qrCodeUrl;
  final List<String>? backupCodes;

  TwoFactorSetupModel({
    required this.secret,
    required this.qrCode,
    this.qrCodeUrl,
    this.backupCodes,
  });

  factory TwoFactorSetupModel.fromJson(Map<String, dynamic> json) {
    return TwoFactorSetupModel(
      secret: json['secret'],
      qrCode: json['qrCode'] ?? json['qrCodeUrl'] ?? json['otpauthUrl'] ?? '',
      qrCodeUrl: json['qrCodeUrl'] ?? json['otpauthUrl'],
      backupCodes: json['backupCodes'] != null
          ? List<String>.from(json['backupCodes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'secret': secret,
        'qrCode': qrCode,
        'qrCodeUrl': qrCodeUrl,
        'backupCodes': backupCodes,
      };
}
