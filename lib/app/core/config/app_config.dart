import 'package:taste_o_clock/app/core/config/env_config.dart';

/// Application-wide configuration constants.
class AppConfig {
  AppConfig._();

  static const String appName = "Taste O'Clock";
  static const String appVersion = '1.0.0';

  /// OAuth 2.0 Web client ID (client_type 3) from Firebase / google-services.json.
  static const String googleWebClientId =
      '497152219724-dhqt9aakuclj5jf0eeiqupgops8r7j1f.apps.googleusercontent.com';

  /// Deployed Stripe PaymentIntent API (B4A).
  static const String paymentServerBaseUrl =
      'https://paymentserver-7q1hoy0b.b4a.run/';

  static const String stripePaymentIntentUrl =
      '$paymentServerBaseUrl/create-payment-intent';

  static const String stripePaymentServerHealthUrl =
      '$paymentServerBaseUrl/health';

  /// Client-safe Stripe publishable key only (`pk_test_...` or `pk_live_...`).
  static String get stripePublishableKey => EnvConfig.get(
        'STRIPE_PUBLISHABLE_KEY',
        defaultValue: '',
      );

  static const _stripeKeyPlaceholders = {
    'pk_test_your_stripe_key_here',
    'pk_test_your_publishable_key_here',
  };

  /// True when `.env` contains a real Stripe publishable key (not a placeholder).
  static bool get hasValidStripePublishableKey {
    final key = stripePublishableKey.trim();
    if (key.isEmpty) return false;
    if (_stripeKeyPlaceholders.contains(key)) return false;
    if (key.contains('your_') || key.endsWith('_here')) return false;
    if (!key.startsWith('pk_test_') && !key.startsWith('pk_live_')) {
      return false;
    }
    // Real Stripe publishable keys are much longer than placeholders.
    return key.length >= 32;
  }

  static const String stripeCurrency = 'usd';

  static const int apiTimeoutSeconds = 30;
  static const int defaultPageSize = 10;
  static const Duration searchDebounce = Duration(milliseconds: 400);
}
