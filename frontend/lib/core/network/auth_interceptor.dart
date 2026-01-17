import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor(this._dio, this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public routes
    if (_isPublicRoute(options.path)) {
      return handler.next(options);
    }

    // Get access token
    final accessToken = await _secureStorage.read(
      key: AppConfig.accessTokenKey,
    );

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final refreshed = await _refreshToken();

      if (refreshed) {
        // Retry the original request
        try {
          final accessToken = await _secureStorage.read(
            key: AppConfig.accessTokenKey,
          );
          err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';

          final response = await _dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      } else {
        // Clear tokens and redirect to login
        await _clearTokens();
      }
    }

    return handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(
        key: AppConfig.refreshTokenKey,
      );

      if (refreshToken == null) {
        return false;
      }

      final response = await _dio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'skipAuth': true}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['tokens'];
        await _secureStorage.write(
          key: AppConfig.accessTokenKey,
          value: data['accessToken'],
        );
        await _secureStorage.write(
          key: AppConfig.refreshTokenKey,
          value: data['refreshToken'],
        );
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: AppConfig.accessTokenKey);
    await _secureStorage.delete(key: AppConfig.refreshTokenKey);
    await _secureStorage.delete(key: AppConfig.userKey);
  }

  bool _isPublicRoute(String path) {
    final publicRoutes = [
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
      '/auth/reset-password',
      '/auth/verify-email',
      '/auth/resend-verification',
      '/auth/refresh-token',
      '/reports/categories',
      '/reports/track',
    ];

    return publicRoutes.any((route) => path.contains(route));
  }
}
