import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/widgets/fade_slide_in.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_controller.dart';
import 'package:taste_o_clock/app/modules/order/widgets/order_status_chip.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_decorations.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class ActiveOrderBanner extends StatelessWidget {
  const ActiveOrderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      id: OrderController.activeOrderUiId,
      builder: (orderController) {
        final activeOrder = orderController.activeOrderState.value;
        if (activeOrder == null) {
          return const SizedBox.shrink();
        }

        return FadeSlideIn(
          key: ValueKey(activeOrder.id),
          slideOffset: const Offset(0, -0.1),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => orderController.openOrderTracking(activeOrder),
                borderRadius: BorderRadius.circular(18.r),
                child: Ink(
                  decoration: AppDecorations.surfaceCard(radius: 18.r).copyWith(
                    border: Border.all(
                      color: AppColors.kPrimary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            gradient: AppColors.kPrimaryGradient,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Icon(
                            Icons.delivery_dining_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order in progress',
                                style: AppFontStyle.kMulishTextStyle(
                                  fontSize: 14,
                                  c: AppColors.kTextPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                activeOrder.status.label,
                                style: AppFontStyle.kMulishTextStyle(
                                  fontSize: 12,
                                  c: AppColors.kTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OrderStatusChip(status: activeOrder.status),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.kPrimary,
                          size: 22.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
