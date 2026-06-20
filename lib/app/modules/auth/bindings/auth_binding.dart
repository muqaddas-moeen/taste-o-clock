import 'package:get/get.dart';
import 'package:taste_o_clock/app/modules/auth/controllers/auth_controller.dart';

/// Route-level binding for authentication screens.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    }
  }
}
