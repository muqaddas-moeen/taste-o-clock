import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/enums/auth_status.dart';
import 'package:taste_o_clock/app/data/services/local_notification_service.dart';
import 'package:taste_o_clock/app/modules/auth/controllers/auth_controller.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_controller.dart';
import 'package:taste_o_clock/app/routes/app_routes.dart';

class SplashController extends GetxController {
  SplashController({AuthController? authController})
      : _authController = authController ?? Get.find<AuthController>();

  final AuthController _authController;

  @override
  void onReady() {
    super.onReady();
    _resolveInitialRoute();
  }

  Future<void> _resolveInitialRoute() async {
    try {
      await _authController.initializeSession().timeout(
        const Duration(seconds: 8),
      );
    } catch (_) {
      _authController.isSessionReady.value = true;
      _authController.authStatus.value = AuthStatus.unauthenticated;
    }

    if (_authController.isAuthenticated) {
      if (Get.isRegistered<OrderController>()) {
        Get.find<OrderController>().bootstrapAfterLogin();
      }
      await LocalNotificationService.instance.ensureNotificationsEnabled();
      Get.offAllNamed(AppRoutes.productList);
      return;
    }

    Get.offAllNamed(AppRoutes.login);
  }
}
