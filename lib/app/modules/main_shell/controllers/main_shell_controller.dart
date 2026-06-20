import 'package:get/get.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_controller.dart';

enum MainShellTab {
  menu,
  orders,
  cart,
  profile,
}

class MainShellController extends GetxController {
  final RxInt currentIndex = MainShellTab.menu.index.obs;

  void switchTab(int index) {
    if (index < 0 || index >= MainShellTab.values.length) return;
    if (currentIndex.value == index) return;

    currentIndex.value = index;
    _handleTabSelected(index);
  }

  void switchTo(MainShellTab tab) => switchTab(tab.index);

  void _handleTabSelected(int index) {
    if (index == MainShellTab.orders.index &&
        Get.isRegistered<OrderController>()) {
      Get.find<OrderController>().loadInitialOrders();
    }
  }
}
