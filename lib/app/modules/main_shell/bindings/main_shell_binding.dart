import 'package:get/get.dart';
import 'package:taste_o_clock/app/modules/cart/bindings/cart_binding.dart';
import 'package:taste_o_clock/app/modules/main_shell/controllers/main_shell_controller.dart';
import 'package:taste_o_clock/app/modules/main_shell/main_shell_tab_controllers.dart';
import 'package:taste_o_clock/app/modules/order/bindings/order_binding.dart';
import 'package:taste_o_clock/app/modules/profile/bindings/profile_binding.dart';

class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainShellController>(() => MainShellController(), fenix: true);
    MainShellTabControllers.register();
    OrderListBinding().dependencies();
    CartBinding().dependencies();
    ProfileBinding().dependencies();
  }
}
