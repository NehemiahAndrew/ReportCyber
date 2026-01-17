class AppConfig {
  static const String appName = 'ReportCyber';
  static const String appVersion = '1.0.0';

  // API Configuration
  // TODO: Update baseUrl to your production backend URL after deployment
  // For local development, use: http://localhost:3000/api/v1
  // For production (Vercel/Railway): https://your-backend-url.com/api/v1
  static const String baseUrl = 'http://localhost:3000/api/v1';
  static const String prodBaseUrl =
      'https://your-backend-url.vercel.app/api/v1';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_complete';

  // Draft auto-save interval (milliseconds)
  static const int autoSaveInterval = 30000; // 30 seconds

  // File upload limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = [
    'png',
    'jpg',
    'jpeg',
    'pdf',
    'txt',
    'log',
  ];

  // Pagination
  static const int defaultPageSize = 20;

  // Get current base URL based on environment
  static String get apiBaseUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? prodBaseUrl : baseUrl;
  }
}
