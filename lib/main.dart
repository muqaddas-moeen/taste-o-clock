import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/bindings/initial_bindings.dart';
import 'package:taste_o_clock/app/core/config/app_config.dart';
import 'package:taste_o_clock/app/core/init/app_initializer.dart';
import 'package:taste_o_clock/app/data/services/fcm_background_handler.dart';
import 'package:taste_o_clock/app/core/animations/app_animations.dart';
import 'package:taste_o_clock/app/routes/app_pages.dart';
import 'package:taste_o_clock/app/routes/app_routes.dart';
import 'package:taste_o_clock/app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await AppInitializer.init();

  InitialBinding().dependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        getPages: AppPages.routes,
        defaultTransition: AppPageTransitions.standard,
        transitionDuration: AppPageTransitions.duration,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
