import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_o_clock/app/core/enums/order_status.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_decorations.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({
    super.key,
    required this.currentStatus,
  });

  final OrderStatus currentStatus;

  static const List<OrderStatus> _steps = [
    OrderStatus.placed,
    OrderStatus.preparing,
    OrderStatus.onTheWay,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = currentStatus.stepIndex;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: AppDecorations.surfaceCard(radius: 18.r),
      child: Column(
        children: List.generate(_steps.length, (index) {
          final step = _steps[index];
          final isCompleted = index <= activeIndex;
          final isLast = index == _steps.length - 1;

          return _TimelineStep(
            title: step.label,
            icon: _iconForStep(step),
            isCompleted: isCompleted,
            isActive: index == activeIndex,
            showConnector: !isLast,
            connectorCompleted: index < activeIndex,
          );
        }),
      ),
    );
  }

  IconData _iconForStep(OrderStatus status) {
    return switch (status) {
      OrderStatus.placed => Icons.receipt_long_rounded,
      OrderStatus.preparing => Icons.restaurant_rounded,
      OrderStatus.onTheWay => Icons.delivery_dining_rounded,
      OrderStatus.delivered => Icons.check_circle_rounded,
    };
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.icon,
    required this.isCompleted,
    required this.isActive,
    required this.showConnector,
    required this.connectorCompleted,
  });

  final String title;
  final IconData icon;
  final bool isCompleted;
  final bool isActive;
  final bool showConnector;
  final bool connectorCompleted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                gradient: isCompleted ? AppColors.kPrimaryGradient : null,
                color: isCompleted ? null : AppColors.kChipInactive,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? AppColors.kPrimary
                      : isCompleted
                          ? Colors.transparent
                          : AppColors.kBorder,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Icon(
                icon,
                size: 18.sp,
                color: isCompleted ? Colors.white : AppColors.kTextMuted,
              ),
            ),
            if (showConnector)
              Container(
                width: 2.w,
                height: 30.h,
                margin: EdgeInsets.symmetric(vertical: 4.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.r),
                  gradient: connectorCompleted
                      ? AppColors.kPrimaryGradient
                      : null,
                  color: connectorCompleted ? null : AppColors.kBorder,
                ),
              ),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 9.h),
            child: Text(
              title,
              style: AppFontStyle.kMulishTextStyle(
                fontSize: 14,
                c: isCompleted
                    ? AppColors.kTextPrimary
                    : AppColors.kTextSecondary,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
