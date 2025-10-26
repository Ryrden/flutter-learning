/// Base class for all custom exceptions in the application
/// Follows Single Responsibility Principle - handles error representation
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when a server error occurs
class ServerException extends AppException {
  const ServerException(super.message, [super.code]);
}

/// Exception thrown when a cache error occurs
class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

/// Exception thrown when user is not authorized
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, [super.code]);
}

/// Exception thrown when resource is not found
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.code]);
}