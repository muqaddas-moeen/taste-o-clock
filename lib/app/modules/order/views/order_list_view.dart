import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/widgets/fade_slide_in.dart';
import 'package:taste_o_clock/app/core/widgets/section_card.dart';
import 'package:taste_o_clock/app/modules/main_shell/widgets/app_bottom_nav_bar.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_controller.dart';
import 'package:taste_o_clock/app/modules/order/widgets/order_card.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class OrderListView extends GetView<OrderController> {
  const OrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Orders',
              style: AppFontStyle.kMulishTextStyle(
                fontSize: 20,
                c: AppColors.kTextPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Track active and past orders',
              style: AppFontStyle.kMulishTextStyle(
                fontSize: 12,
                c: AppColors.kTextSecondary,
              ),
            ),
          ],
        ),
      ),
      body: GetBuilder<OrderController>(
        id: OrderController.ordersUiId,
        builder: (controller) {
          if (controller.isLoading.value && controller.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.orders.isEmpty) {
            return const EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              subtitle: 'Place an order from your cart to see it here',
            );
          }

          final activeOrders = controller.activeOrders;
          final pastOrders = controller.pastOrders;

          return RefreshIndicator(
            color: AppColors.kPrimary,
            onRefresh: () => controller.loadInitialOrders(forceRefresh: true),
            child: ListView(
              controller: controller.scrollController,
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.h,
                16.w,
                24.h + MainShellInsets.contentBottom(context),
              ),
              children: [
                if (activeOrders.isNotEmpty) ...[
                  FadeSlideIn(
                    child: Text(
                      'Active Orders',
                      style: AppFontStyle.kMulishTextStyle(
                        fontSize: 15,
                        c: AppColors.kTextPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...activeOrders.asMap().entries.map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: StaggeredEntrance(
                        index: entry.key,
                        child: OrderCard(
                          order: entry.value,
                          onTap: () => controller.openOrderTracking(entry.value),
                        ),
                      ),
                    ),
                  ),
                ],
                if (pastOrders.isNotEmpty) ...[
                  if (activeOrders.isNotEmpty) SizedBox(height: 8.h),
                  Text(
                    'Past Orders',
                    style: AppFontStyle.kMulishTextStyle(
                      fontSize: 15,
                      c: AppColors.kTextPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...pastOrders.asMap().entries.map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: StaggeredEntrance(
                        index: entry.key + activeOrders.length,
                        child: OrderCard(
                          order: entry.value,
                          onTap: () => controller.openOrderTracking(entry.value),
                        ),
                      ),
                    ),
                  ),
                ],
                if (controller.isLoadingMore.value)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
