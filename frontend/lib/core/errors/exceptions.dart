/// Base exception class for the application
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException: $message';
}

/// Exception for server-side errors
class ServerException extends AppException {
  final int? statusCode;

  ServerException({
    required super.message,
    super.code,
    super.details,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Exception for cache/storage errors
class CacheException extends AppException {
  CacheException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() => 'CacheException: $message';
}

/// Exception for network connectivity errors
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception for authentication errors
class AuthException extends AppException {
  AuthException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() => 'AuthException: $message';
}

/// Exception for validation errors
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException({
    required super.message,
    super.code,
    super.details,
    this.fieldErrors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception for not found errors
class NotFoundException extends AppException {
  NotFoundException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception for unauthorized access
class UnauthorizedException extends AppException {
  UnauthorizedException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Exception for forbidden access
class ForbiddenException extends AppException {
  ForbiddenException({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String toString() => 'ForbiddenException: $message';
}
