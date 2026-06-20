import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:taste_o_clock/app/core/utils/app_log.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:taste_o_clock/app/core/config/app_config.dart';
import 'package:taste_o_clock/app/core/errors/failure.dart';
import 'package:taste_o_clock/app/core/network/result.dart';

/// Stripe PaymentSheet checkout for card payments.
class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();

  bool _initialized = false;
  bool _initAttempted = false;

  bool get isStripeConfigured => AppConfig.hasValidStripePublishableKey;

  bool get isStripeReady => _initialized;

  /// Ping deployed payment API before card checkout.
  Future<Result<void>> checkPaymentServerHealth() async {
    try {
      final response = await http
          .get(Uri.parse(AppConfig.stripePaymentServerHealthUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return Error(
          AppFailure(
            code: 'payment_server_error',
            message:
                'Payment server returned ${response.statusCode}. Check your deployed server.',
          ),
        );
      }

      final body = jsonDecode(response.body);
      if (body is! Map || body['ok'] != true) {
        return const Error(
          AppFailure(
            code: 'payment_server_error',
            message: 'Payment server health check failed.',
          ),
        );
      }

      if (body['stripeConfigured'] != true) {
        return const Error(
          AppFailure(
            code: 'stripe_secret_missing',
            message:
                'Payment server is not configured for card payments yet.',
          ),
        );
      }

      return const Success(null);
    } catch (error) {
      AppLog.d('[PaymentServer] Health check failed: $error');
      return const Error(
        AppFailure(
          code: 'payment_server_unreachable',
          message:
              'Cannot reach the payment server. Check your internet connection.',
        ),
      );
    }
  }

  Future<void> initialize() async {
    if (_initAttempted) return;
    _initAttempted = true;

    if (!isStripeConfigured) {
      AppLog.d('[Stripe] Publishable key not configured.');
      return;
    }

    try {
      Stripe.publishableKey = AppConfig.stripePublishableKey;
      await Stripe.instance.applySettings();
      _initialized = true;
      AppLog.d('[Stripe] PaymentSheet initialized.');
    } on PlatformException catch (error) {
      AppLog.d('[Stripe] Init failed: ${error.message}');
    } catch (error) {
      AppLog.d('[Stripe] Init failed: $error');
    }
  }

  Future<Result<void>> payWithCard({
    required double amount,
    String currency = AppConfig.stripeCurrency,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    if (!isStripeConfigured) {
      return const Error(
        AppFailure(
          code: 'stripe_not_configured',
          message: 'Card payments are not available right now.',
        ),
      );
    }

    if (!_initialized) {
      return const Error(
        AppFailure(
          code: 'stripe_init_failed',
          message:
              'Stripe failed to initialize. Restart the app after fixing Android theme setup.',
        ),
      );
    }

    final intentUrl = AppConfig.stripePaymentIntentUrl;

    try {
      final clientSecret = await _fetchPaymentIntentClientSecret(
        amount: amount,
        currency: currency,
        intentUrl: intentUrl,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: AppConfig.appName,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return const Success(null);
    } on StripeException catch (error) {
      if (error.error.code == FailureCode.Canceled) {
        return const Error(
          AppFailure(
            code: 'payment_cancelled',
            message: 'Payment was cancelled.',
          ),
        );
      }

      return Error(
        AppFailure(
          code: 'stripe_error',
          message: error.error.localizedMessage ?? 'Card payment failed.',
        ),
      );
    } on AppFailure catch (failure) {
      return Error(failure);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'payment_error',
          message: 'Unable to process card payment. Please try again.',
        ),
      );
    }
  }

  Future<String> _fetchPaymentIntentClientSecret({
    required double amount,
    required String currency,
    required String intentUrl,
  }) async {
    final amountCents = (amount * 100).round();
    if (amountCents <= 0) {
      throw const AppFailure(
        code: 'invalid_amount',
        message: 'Order total must be greater than zero.',
      );
    }

    final response = await http
        .post(
          Uri.parse(intentUrl),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'amount': amountCents,
            'currency': currency,
          }),
        )
        .timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));

    if (response.statusCode != 200) {
      final serverMessage = _readServerErrorMessage(response.body);
      throw AppFailure(
        code: 'payment_intent_error',
        message: serverMessage ??
            'Payment server error (${response.statusCode}).',
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map) {
      throw const AppFailure(
        code: 'payment_intent_error',
        message: 'Invalid response from payment server.',
      );
    }

    final clientSecret = body['clientSecret'] as String?;
    if (clientSecret == null || clientSecret.isEmpty) {
      throw const AppFailure(
        code: 'payment_intent_error',
        message: 'Payment server did not return a client secret.',
      );
    }

    return clientSecret;
  }

  String? _readServerErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final error = decoded['error'];
        if (error is String && error.trim().isNotEmpty) {
          return error.trim();
        }
      }
    } catch (_) {
      // Ignore malformed error payloads.
    }
    return null;
  }
}
