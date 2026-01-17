import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
    String? totpCode,
  }) async {
    try {
      final response = await remoteDataSource.login(
        email: email,
        password: password,
        totpCode: totpCode,
      );

      if (response.requires2FA) {
        return AuthResult(
          success: false,
          requires2FA: true,
          tempUserId: response.tempUserId,
          message: 'Two-factor authentication required',
        );
      }

      if (response.accessToken != null && response.refreshToken != null) {
        await localDataSource.cacheTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );

        if (response.user != null) {
          await localDataSource.cacheUser(response.user!);
        }
      }

      return AuthResult(
        success: true,
        user: response.user?.toEntity(),
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        message: response.message ?? 'Login successful',
      );
    } catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e));
    }
  }

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
  }) async {
    try {
      final response = await remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      return AuthResult(
        success: true,
        user: response.user?.toEntity(),
        message: response.message ??
            'Registration successful. Please verify your email.',
      );
    } catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e));
    }
  }

  @override
  Future<void> verifyEmail(String token) async {
    await remoteDataSource.verifyEmail(token: token);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await remoteDataSource.forgotPassword(email: email);
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await remoteDataSource.resetPassword(
      token: token,
      newPassword: password,
    );
  }

  @override
  Future<AuthResult> refreshToken() async {
    try {
      final storedRefreshToken = await localDataSource.getRefreshToken();
      if (storedRefreshToken == null) {
        return AuthResult(
          success: false,
          message: 'No refresh token available',
        );
      }

      final response = await remoteDataSource.refreshToken(
        refreshToken: storedRefreshToken,
      );

      if (response.accessToken != null && response.refreshToken != null) {
        await localDataSource.cacheTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );
      }

      return AuthResult(
        success: true,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        message: 'Token refreshed successfully',
      );
    } catch (e) {
      await localDataSource.clearCache();
      return AuthResult(success: false, message: _getErrorMessage(e));
    }
  }

  @override
  Future<AuthResult> googleSignIn() async {
    // Google Sign-In v7.x uses a new stream-based API
    // This requires platform-specific configuration
    // For now, return a placeholder - implement fully when platform setup is complete
    try {
      // The new API uses GoogleSignIn.instance.authenticate()
      // and requires proper clientId setup
      return AuthResult(
        success: false,
        message:
            'Google Sign-In requires platform configuration. Please configure Google Cloud Console credentials.',
      );
    } catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e));
    }
  }

  @override
  Future<AuthResult> githubSignIn() async {
    // GitHub OAuth flow would typically use a web view or browser
    // This is a placeholder - implementation would depend on OAuth flow
    return AuthResult(
      success: false,
      message: 'GitHub sign in not implemented for mobile',
    );
  }

  @override
  Future<TwoFactorSetupResult> setup2FA() async {
    try {
      final accessToken = await localDataSource.getAccessToken();
      if (accessToken == null) {
        return TwoFactorSetupResult(
          success: false,
          secret: '',
          qrCode: '',
          message: 'Not authenticated',
        );
      }

      final response = await remoteDataSource.setup2FA(
        accessToken: accessToken,
      );

      return TwoFactorSetupResult(
        success: true,
        secret: response.secret,
        qrCode: response.qrCode,
        qrCodeUrl: response.qrCodeUrl,
        backupCodes: response.backupCodes,
        message: '2FA setup initiated',
      );
    } catch (e) {
      return TwoFactorSetupResult(
        success: false,
        secret: '',
        qrCode: '',
        message: _getErrorMessage(e),
      );
    }
  }

  @override
  Future<AuthResult> verify2FA({
    required String userId,
    required String totpCode,
  }) async {
    try {
      final response = await remoteDataSource.verify2FA(
        userId: userId,
        totpCode: totpCode,
      );

      if (response.accessToken != null && response.refreshToken != null) {
        await localDataSource.cacheTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );

        if (response.user != null) {
          await localDataSource.cacheUser(response.user!);
        }
      }

      return AuthResult(
        success: true,
        user: response.user?.toEntity(),
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        message: '2FA verification successful',
      );
    } catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e));
    }
  }

  @override
  Future<void> disable2FA(
      {required String password, required String totpCode}) async {
    final accessToken = await localDataSource.getAccessToken();
    if (accessToken == null) {
      throw Exception('Not authenticated');
    }

    await remoteDataSource.disable2FA(
      accessToken: accessToken,
      totpCode: totpCode,
    );
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken != null) {
        await remoteDataSource.logout(refreshToken: refreshToken);
      }
    } finally {
      await localDataSource.clearCache();
      // GoogleSignIn v7.x uses GoogleSignIn.instance.signOut()
      // Skipping for now as it requires proper initialization
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final accessToken = await localDataSource.getAccessToken();
      if (accessToken == null) {
        // Try to get cached user
        final cachedUser = await localDataSource.getCachedUser();
        return cachedUser?.toEntity();
      }

      final userModel = await remoteDataSource.getCurrentUser(
        accessToken: accessToken,
      );
      await localDataSource.cacheUser(userModel);
      return userModel.toEntity();
    } catch (e) {
      // Fall back to cached user
      final cachedUser = await localDataSource.getCachedUser();
      return cachedUser?.toEntity();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final accessToken = await localDataSource.getAccessToken();
    return accessToken != null;
  }

  @override
  Future<void> logoutAll() async {
    try {
      final accessToken = await localDataSource.getAccessToken();
      if (accessToken != null) {
        await remoteDataSource.logoutAll(accessToken: accessToken);
      }
    } finally {
      await localDataSource.clearCache();
      // GoogleSignIn v7.x uses GoogleSignIn.instance.signOut()
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final accessToken = await localDataSource.getAccessToken();
    if (accessToken == null) {
      throw Exception('Not authenticated');
    }
    await remoteDataSource.changePassword(
      accessToken: accessToken,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<List<String>> generateBackupCodes(String password) async {
    final accessToken = await localDataSource.getAccessToken();
    if (accessToken == null) {
      throw Exception('Not authenticated');
    }
    return await remoteDataSource.generateBackupCodes(
      accessToken: accessToken,
      password: password,
    );
  }

  @override
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? phone,
  }) async {
    final accessToken = await localDataSource.getAccessToken();
    if (accessToken == null) {
      throw Exception('Not authenticated');
    }
    final userModel = await remoteDataSource.updateProfile(
      accessToken: accessToken,
      firstName: firstName,
      lastName: lastName,
      bio: bio,
      phone: phone,
    );
    await localDataSource.cacheUser(userModel);
    return userModel.toEntity();
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    await remoteDataSource.resendVerificationEmail(email: email);
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}
