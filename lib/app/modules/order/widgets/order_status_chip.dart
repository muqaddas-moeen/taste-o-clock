import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_o_clock/app/core/enums/order_status.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({
    super.key,
    required this.status,
  });

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.label,
        style: AppFontStyle.kMulishTextStyle(
          fontSize: 12,
          c: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _colorForStatus(OrderStatus status) {
    return switch (status) {
      OrderStatus.placed => AppColors.kPrimary,
      OrderStatus.preparing => AppColors.kSecondary,
      OrderStatus.onTheWay => AppColors.kWarning,
      OrderStatus.delivered => AppColors.kSuccess,
    };
  }
}
