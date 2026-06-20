import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taste_o_clock/app/core/utils/app_log.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taste_o_clock/app/core/config/env_config.dart';
import 'package:taste_o_clock/app/data/services/local_notification_service.dart';
import 'package:taste_o_clock/app/data/services/payment_service.dart';
import 'package:taste_o_clock/app/data/services/push_notification_service.dart';
import 'package:taste_o_clock/app/data/services/storage_service.dart';
import 'package:taste_o_clock/firebase_options.dart';

/// Centralized bootstrap sequence for the application.
class AppInitializer {
  AppInitializer._();

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    await _loadEnv();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await StorageService.init();
    await LocalNotificationService.instance.initialize();
    await PushNotificationService.instance.initialize();
    await PaymentService.instance.initialize();
  }

  static Future<void> _loadEnv() async {
    try {
      await dotenv.load(fileName: '.env');
      EnvConfig.assertClientSafeEnv();
      AppLog.d('[Config] Loaded .env');
    } catch (error) {
      AppLog.d(
        '[Config] .env not loaded ($error). '
        'Copy .env.example to .env or use --dart-define.',
      );
    }
  }
}
