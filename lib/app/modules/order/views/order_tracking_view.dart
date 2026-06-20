import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/widgets/fade_slide_in.dart';
import 'package:taste_o_clock/app/core/widgets/section_card.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_tracking_controller.dart';
import 'package:taste_o_clock/app/modules/order/widgets/order_status_chip.dart';
import 'package:taste_o_clock/app/modules/order/widgets/order_status_timeline.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_decorations.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';
import 'package:taste_o_clock/app/utils/helpers.dart';

class OrderTrackingView extends GetView<OrderTrackingController> {
  const OrderTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track Order',
              style: AppFontStyle.kMulishTextStyle(
                fontSize: 20,
                c: AppColors.kTextPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Live delivery updates',
              style: AppFontStyle.kMulishTextStyle(
                fontSize: 12,
                c: AppColors.kTextSecondary,
              ),
            ),
          ],
        ),
      ),
      body: GetBuilder<OrderTrackingController>(
        id: OrderTrackingController.trackingUiId,
        builder: (controller) {
          final order = controller.order.value;
          if (order == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16.w),
                  children: [
                    FadeSlideIn(
                      child: SectionCard(
                        icon: Icons.receipt_long_outlined,
                        title:
                            'Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                        trailing: OrderStatusChip(status: order.status),
                        child: Text(
                          '${order.totalItems} item${order.totalItems == 1 ? '' : 's'} • ${Helpers.formatPrice(order.subtotal)}',
                          style: AppFontStyle.kMulishTextStyle(
                            fontSize: 14,
                            c: AppColors.kTextSecondary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery Status',
                            style: AppFontStyle.kMulishTextStyle(
                              fontSize: 15,
                              c: AppColors.kTextPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          OrderStatusTimeline(currentStatus: order.status),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 140),
                      child: SectionCard(
                        icon: Icons.payment_outlined,
                        title: 'Payment',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.paymentSummaryLabel,
                              style: AppFontStyle.kMulishTextStyle(
                                fontSize: 15,
                                c: AppColors.kTextPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              order.paymentStatusLabel,
                              style: AppFontStyle.kMulishTextStyle(
                                fontSize: 13,
                                c: AppColors.kTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Items',
                      style: AppFontStyle.kMulishTextStyle(
                        fontSize: 15,
                        c: AppColors.kTextPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...order.items.asMap().entries.map(
                      (entry) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: StaggeredEntrance(
                          index: entry.key,
                          child: Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: AppDecorations.surfaceCard(radius: 14.r),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.value.name,
                                    style: AppFontStyle.kMulishTextStyle(
                                      fontSize: 14,
                                      c: AppColors.kTextPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Text(
                                  'x${entry.value.quantity}',
                                  style: AppFontStyle.kMulishTextStyle(
                                    fontSize: 13,
                                    c: AppColors.kTextSecondary,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  Helpers.formatPrice(entry.value.lineTotal),
                                  style: AppFontStyle.kMulishTextStyle(
                                    fontSize: 14,
                                    c: AppColors.kPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: GradientPrimaryButton(
                    label: 'Continue Shopping',
                    onPressed: controller.continueShopping,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
