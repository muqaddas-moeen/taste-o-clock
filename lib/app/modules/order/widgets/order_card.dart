import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_o_clock/app/core/widgets/scale_tap.dart';
import 'package:taste_o_clock/app/data/models/order_model.dart';
import 'package:taste_o_clock/app/modules/order/widgets/order_status_chip.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_decorations.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';
import 'package:taste_o_clock/app/utils/helpers.dart';

String _formatOrderDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final period = date.hour >= 12 ? 'PM' : 'AM';
  final minute = date.minute.toString().padLeft(2, '0');
  return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $period';
}

String _shortOrderId(String id) {
  if (id.length <= 8) return id;
  return id.substring(0, 8);
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatOrderDate(order.createdAt);

    return ScaleTap(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: AppDecorations.surfaceCard(radius: 18.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${_shortOrderId(order.id)}',
                    style: AppFontStyle.kMulishTextStyle(
                      fontSize: 15,
                      c: AppColors.kTextPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                OrderStatusChip(status: order.status),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              dateLabel,
              style: AppFontStyle.kMulishTextStyle(
                fontSize: 12,
                c: AppColors.kTextSecondary,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              '${order.totalItems} item${order.totalItems == 1 ? '' : 's'}',
              style: AppFontStyle.kMulishTextStyle(
                fontSize: 13,
                c: AppColors.kTextSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Text(
                  Helpers.formatPrice(order.subtotal),
                  style: AppFontStyle.kMulishTextStyle(
                    fontSize: 16,
                    c: AppColors.kPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.kTextSecondary,
                  size: 22.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
