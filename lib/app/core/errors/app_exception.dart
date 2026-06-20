import 'package:taste_o_clock/app/core/errors/failure.dart';

/// Domain-level exception mapped to [AppFailure] at the repository boundary.
class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.cause,
  });

  final String message;
  final String? code;
  final Object? cause;

  AppFailure toFailure() => AppFailure(
        message: message,
        code: code,
      );

  @override
  String toString() => 'AppException($code): $message';
}
