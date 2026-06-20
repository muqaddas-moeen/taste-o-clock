import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/modules/cart/views/cart_view.dart';
import 'package:taste_o_clock/app/modules/main_shell/controllers/main_shell_controller.dart';
import 'package:taste_o_clock/app/modules/main_shell/widgets/app_bottom_nav_bar.dart';
import 'package:taste_o_clock/app/modules/order/views/order_list_view.dart';
import 'package:taste_o_clock/app/modules/product/views/product_list_view.dart';
import 'package:taste_o_clock/app/modules/profile/views/profile_view.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';

class MainShellView extends GetView<MainShellController> {
  const MainShellView({super.key});

  static final _tabs = [
    const SizedBox.expand(child: ProductListView()),
    const SizedBox.expand(child: OrderListView()),
    const SizedBox.expand(child: CartView()),
    const SizedBox.expand(child: ProfileView()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      extendBody: true,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: Obx(
        () => AppBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.switchTab,
        ),
      ),
    );
  }
}
