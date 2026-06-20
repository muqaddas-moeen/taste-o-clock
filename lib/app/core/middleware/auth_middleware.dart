import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/modules/auth/controllers/auth_controller.dart';
import 'package:taste_o_clock/app/routes/app_routes.dart';

/// Protects routes that require an authenticated session.
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      if (authController.isSessionReady.value) {
        if (authController.isAuthenticated) {
          return null;
        }
        return const RouteSettings(name: AppRoutes.login);
      }
    }

    // Firebase may still hold a session before AuthController finishes bootstrapping.
    if (FirebaseAuth.instance.currentUser != null) {
      return null;
    }

    if (!Get.isRegistered<AuthController>() ||
        !Get.find<AuthController>().isSessionReady.value) {
      return const RouteSettings(name: AppRoutes.splash);
    }

    return const RouteSettings(name: AppRoutes.login);
  }
}
