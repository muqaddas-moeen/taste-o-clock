import 'package:taste_o_clock/app/core/errors/failure.dart';

class AuthFailureMapper {
  AuthFailureMapper._();

  static AppFailure fromCode(String? code, {String? fallbackMessage}) {
    return AppFailure(
      code: code,
      message: _messages[code] ?? fallbackMessage ?? 'Authentication failed.',
    );
  }

  static const Map<String, String> _messages = {
    'sign_in_cancelled': 'Google sign-in was cancelled.',
    'account-exists-with-different-credential':
        'An account already exists with a different sign-in method.',
    'invalid-credential': 'Invalid credentials. Please try again.',
    'operation-not-allowed': 'Google sign-in is not enabled for this app.',
    'user-disabled': 'This account has been disabled.',
    'network-request-failed': 'Network error. Check your connection.',
    'missing_user': 'Signed in but user profile is unavailable.',
    'auth_error': 'Unable to complete Google sign-in.',
    'sign_out_error': 'Failed to sign out.',
    'sync_error': 'Unable to sync user session.',
    'permission-denied': 'You do not have permission to access this account.',
  };
}
