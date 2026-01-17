import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_remote_data_source.dart';

/// Local data source for caching auth data
abstract class AuthLocalDataSource {
  /// Cache tokens
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Get cached access token
  Future<String?> getAccessToken();

  /// Get cached refresh token
  Future<String?> getRefreshToken();

  /// Cache user data
  Future<void> cacheUser(UserModel user);

  /// Get cached user
  Future<UserModel?> getCachedUser();

  /// Clear all cached auth data
  Future<void> clearCache();

  /// Check if user is logged in
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'cached_user';

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      secureStorage.write(key: _accessTokenKey, value: accessToken),
      secureStorage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final userJson = json.encode(user.toJson());
    await secureStorage.write(key: _userKey, value: userJson);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = await secureStorage.read(key: _userKey);
    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    await Future.wait([
      secureStorage.delete(key: _accessTokenKey),
      secureStorage.delete(key: _refreshTokenKey),
      secureStorage.delete(key: _userKey),
    ]);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
