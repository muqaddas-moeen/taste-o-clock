import 'package:get/get.dart';
import 'package:taste_o_clock/app/modules/cart/controllers/cart_controller.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.find<CartController>();
    Get.find<OrderController>();
  }
}
