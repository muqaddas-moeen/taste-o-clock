import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taste_o_clock/app/core/utils/app_log.dart';

/// Loads client-safe config from `.env` (publishable Stripe key only).
class EnvConfig {
  EnvConfig._();

  static const _blockedKeys = {
    'STRIPE_SECRET_KEY',
    'PAYMENT_API_KEY',
    'STRIPE_PAYMENT_INTENT_URL',
  };

  static String get(String key, {String defaultValue = ''}) {
    final fromDotenv = dotenv.maybeGet(key)?.trim();
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }

    return String.fromEnvironment(key, defaultValue: defaultValue);
  }

  /// Warns if server-only or sensitive keys were placed in the Flutter `.env`.
  static void assertClientSafeEnv() {
    for (final key in _blockedKeys) {
      final value = dotenv.maybeGet(key)?.trim();
      if (value == null || value.isEmpty) continue;

      AppLog.d(
        '[Config] SECURITY: Remove $key from the Flutter .env. '
        'Secret keys belong on the deployed server only.',
      );
    }
  }
}
