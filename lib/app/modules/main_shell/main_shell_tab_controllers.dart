import 'package:get/get.dart';
import 'package:taste_o_clock/app/modules/product/bindings/product_binding.dart';
import 'package:taste_o_clock/app/modules/product/controllers/product_controller.dart';
import 'package:taste_o_clock/app/modules/profile/controllers/profile_controller.dart';

/// Registers shell tab controllers that must outlive nested routes (e.g. product detail).
class MainShellTabControllers {
  MainShellTabControllers._();

  static void register() {
    ProductBinding().dependencies();

    if (!Get.isRegistered<ProductController>()) {
      Get.put<ProductController>(ProductController(), permanent: true);
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.put<ProfileController>(ProfileController(), permanent: true);
    }
  }

  static void dispose() {
    if (Get.isRegistered<ProductController>()) {
      Get.delete<ProductController>(force: true);
    }
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>(force: true);
    }
  }
}
