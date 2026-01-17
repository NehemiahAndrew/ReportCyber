import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/network/api_client.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final GoogleSignIn googleSignInClient;

  AuthRemoteDataSourceImpl({
    required this.apiClient,
    required GoogleSignIn googleSignIn,
  }) : googleSignInClient = googleSignIn;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    String? totpCode,
  }) async {
    final response = await apiClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
        if (totpCode != null) 'totpCode': totpCode,
      },
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
  }) async {
    final response = await apiClient.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
      },
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<void> verifyEmail({required String token}) async {
    await apiClient.get('/auth/verify-email/$token');
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await apiClient.post('/auth/forgot-password', data: {'email': email});
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await apiClient.post(
      '/auth/reset-password/$token',
      data: {'password': newPassword},
    );
  }

  @override
  Future<AuthResponseModel> refreshToken({required String refreshToken}) async {
    final response = await apiClient.post(
      '/auth/refresh-token',
      data: {'refreshToken': refreshToken},
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> googleSignIn({required String idToken}) async {
    final response = await apiClient.post(
      '/auth/google/mobile',
      data: {'idToken': idToken},
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> githubSignIn({required String code}) async {
    final response = await apiClient.post(
      '/auth/github/mobile',
      data: {'code': code},
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<TwoFactorSetupModel> setup2FA({required String accessToken}) async {
    final response = await apiClient.post(
      '/auth/2fa/setup',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return TwoFactorSetupModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> verify2FA({
    required String userId,
    required String totpCode,
  }) async {
    final response = await apiClient.post(
      '/auth/2fa/verify',
      data: {'userId': userId, 'totpCode': totpCode},
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<void> disable2FA({
    required String accessToken,
    required String totpCode,
  }) async {
    await apiClient.post(
      '/auth/2fa/disable',
      data: {'totpCode': totpCode},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    await apiClient.post('/auth/logout', data: {'refreshToken': refreshToken});
  }

  @override
  Future<void> logoutAll({required String accessToken}) async {
    await apiClient.post(
      '/auth/logout-all',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  @override
  Future<UserModel> getCurrentUser({required String accessToken}) async {
    final response = await apiClient.get(
      '/users/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return UserModel.fromJson(response.data['user']);
  }

  @override
  Future<UserModel> updateProfile({
    required String accessToken,
    String? firstName,
    String? lastName,
    String? bio,
    String? phone,
  }) async {
    final response = await apiClient.patch(
      '/users/me',
      data: {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (bio != null) 'bio': bio,
        if (phone != null) 'phoneNumber': phone,
      },
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return UserModel.fromJson(response.data['user']);
  }

  @override
  Future<void> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  }) async {
    await apiClient.post(
      '/users/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  @override
  Future<List<String>> generateBackupCodes({
    required String accessToken,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/auth/2fa/backup-codes',
      data: {'password': password},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return List<String>.from(response.data['backupCodes']);
  }

  @override
  Future<void> resendVerificationEmail({required String email}) async {
    await apiClient.post('/auth/resend-verification', data: {'email': email});
  }
}
