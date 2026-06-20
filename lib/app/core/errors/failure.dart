/// Immutable failure object returned from repositories to controllers.
class AppFailure {
  const AppFailure({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;

  @override
  String toString() => 'AppFailure($code): $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppFailure && message == other.message && code == other.code;

  @override
  int get hashCode => Object.hash(message, code);
}
