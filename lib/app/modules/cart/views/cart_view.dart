import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/widgets/fade_slide_in.dart';
import 'package:taste_o_clock/app/core/widgets/section_card.dart';
import 'package:taste_o_clock/app/data/models/cart_item_model.dart';
import 'package:taste_o_clock/app/modules/cart/controllers/cart_controller.dart';
import 'package:taste_o_clock/app/modules/cart/widgets/cart_item_tile.dart';
import 'package:taste_o_clock/app/modules/cart/widgets/cart_summary_bar.dart';
import 'package:taste_o_clock/app/modules/main_shell/controllers/main_shell_controller.dart';
import 'package:taste_o_clock/app/modules/main_shell/widgets/app_bottom_nav_bar.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_controller.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  void _browseMenu() {
    if (Get.isRegistered<MainShellController>()) {
      Get.find<MainShellController>().switchTo(MainShellTab.menu);
      return;
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final navClearance = MainShellInsets.isInMainShell
        ? AppBottomNavBar.overlayHeight(context)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Cart',
                style: AppFontStyle.kMulishTextStyle(
                  fontSize: 20,
                  c: AppColors.kTextPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                controller.items.isEmpty
                    ? 'No items yet'
                    : '${controller.totalItems.value} ${controller.totalItems.value == 1 ? 'item' : 'items'} · ${controller.items.length} ${controller.items.length == 1 ? 'dish' : 'dishes'}',
                style: AppFontStyle.kMulishTextStyle(
                  fontSize: 12,
                  c: AppColors.kTextSecondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Obx(
            () => controller.items.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: controller.clearCart,
                    child: Text(
                      'Clear all',
                      style: AppFontStyle.kMulishTextStyle(
                        fontSize: 13,
                        c: AppColors.kError,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.items.isEmpty) {
          return _EmptyCartBody(
            navClearance: navClearance,
            onBrowseMenu: _browseMenu,
          );
        }

        return _CartItemsList(items: List<CartItemModel>.from(controller.items));
      }),
      bottomNavigationBar: Obx(() {
        if (controller.items.isEmpty) {
          return SizedBox(height: navClearance);
        }

        final orderController = Get.find<OrderController>();
        return Padding(
          padding: EdgeInsets.only(bottom: navClearance),
          child: CartSummaryBar(
            totalItems: controller.totalItems.value,
            subtotal: controller.subtotal.value,
            buttonLabel: 'Proceed to Checkout',
            enabled: !orderController.isPlacingOrder.value,
            onPressed: orderController.proceedToCheckout,
            includeBottomSafeArea: !MainShellInsets.isInMainShell,
          ),
        );
      }),
    );
  }
}

class _EmptyCartBody extends StatelessWidget {
  const _EmptyCartBody({
    required this.navClearance,
    required this.onBrowseMenu,
  });

  final double navClearance;
  final VoidCallback onBrowseMenu;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24.w,
              0,
              24.w,
              navClearance + 16.h,
            ),
            child: Column(
              children: [
                const Expanded(
                  child: EmptyStateView(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Your cart is empty',
                    subtitle: 'Browse the menu and add dishes you love',
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    onPressed: onBrowseMenu,
                    icon: const Icon(Icons.restaurant_menu_rounded),
                    label: const Text('Browse Menu'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CartItemsList extends GetView<CartController> {
  const _CartItemsList({required this.items});

  final List<CartItemModel> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = items[index];
        return StaggeredEntrance(
          key: ValueKey(item.productId),
          index: index,
          child: CartItemTile(
            item: item,
            onIncrement: () => controller.incrementItem(item.productId),
            onDecrement: () => controller.decrementItem(item.productId),
            onRemove: () => controller.removeItem(item.productId),
          ),
        );
      },
    );
  }
}
