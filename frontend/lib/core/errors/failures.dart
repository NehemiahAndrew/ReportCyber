import 'package:equatable/equatable.dart';

/// Base failure class for the application
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Failure for server-side errors
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(
    String message, {
    super.code,
    this.statusCode,
  }) : super(message: message);

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Failure for cache/storage errors
class CacheFailure extends Failure {
  const CacheFailure(String message, {super.code}) : super(message: message);
}

/// Failure for network connectivity errors
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {super.code}) : super(message: message);
}

/// Failure for authentication errors
class AuthFailure extends Failure {
  const AuthFailure(String message, {super.code}) : super(message: message);
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(
    String message, {
    super.code,
    this.fieldErrors,
  }) : super(message: message);

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Failure for not found errors
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, {super.code}) : super(message: message);
}

/// Failure for unauthorized access
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(String message, {super.code})
      : super(message: message);
}

/// Failure for forbidden access
class ForbiddenFailure extends Failure {
  const ForbiddenFailure(String message, {super.code})
      : super(message: message);
}

/// Generic unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure(String message, {super.code}) : super(message: message);
}
