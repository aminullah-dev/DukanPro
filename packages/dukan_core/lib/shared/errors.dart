/// Error contract. A code is a promise; the wording is not.
///
/// The UI resolves a [code] to a translated message using [context]; the code
/// is the stable contract referenced by translations and the server API.
/// Domain code raises only [ValidationError] and [ConflictError]; everything
/// else is an application/infrastructure concern.
sealed class AppError implements Exception {
  AppError(this.code, [Map<String, Object?>? context])
      : context = context ?? const {};

  /// Stable, machine-readable `<AGGREGATE>_<CONDITION>` code.
  final String code;

  /// Structured data for the translation — never interpolated into a message.
  final Map<String, Object?> context;

  /// HTTP status the server maps this error to.
  int get httpStatus;

  @override
  String toString() => '$runtimeType($code, $context)';
}

final class ValidationError extends AppError {
  ValidationError(super.code, [super.context]);
  @override
  int get httpStatus => 422;
}

final class NotFoundError extends AppError {
  NotFoundError(super.code, [super.context]);
  @override
  int get httpStatus => 404;
}

final class ConflictError extends AppError {
  ConflictError(super.code, [super.context]);
  @override
  int get httpStatus => 409;
}

final class PermissionDeniedError extends AppError {
  PermissionDeniedError(super.code, [super.context]);
  @override
  int get httpStatus => 403;
}

/// Too many attempts; try again later (the sign-in lockout).
final class RateLimitedError extends AppError {
  RateLimitedError(super.code, [super.context]);
  @override
  int get httpStatus => 429;
}

final class LicenseError extends AppError {
  LicenseError(super.code, [super.context]);
  @override
  int get httpStatus => 402;
}

final class IntegrationError extends AppError {
  IntegrationError(super.code, [super.context]);
  @override
  int get httpStatus => 502;
}

final class InfrastructureError extends AppError {
  InfrastructureError(super.code, [super.context]);
  @override
  int get httpStatus => 500;
}
