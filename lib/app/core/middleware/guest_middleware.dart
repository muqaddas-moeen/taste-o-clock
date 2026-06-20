import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/modules/auth/controllers/auth_controller.dart';
import 'package:taste_o_clock/app/routes/app_routes.dart';

/// Redirects authenticated users away from guest-only routes.
class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return null;
    }

    final authController = Get.find<AuthController>();
    if (authController.isSessionReady.value && authController.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.productList);
    }

    return null;
  }
}
