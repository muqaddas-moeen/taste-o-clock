import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_decorations.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';
import 'package:taste_o_clock/app/utils/helpers.dart';

class CartSummaryBar extends StatelessWidget {
  const CartSummaryBar({
    super.key,
    required this.totalItems,
    required this.subtotal,
    required this.buttonLabel,
    required this.onPressed,
    this.enabled = true,
    this.showHandle = true,
    this.includeBottomSafeArea = true,
  });

  final int totalItems;
  final double subtotal;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool enabled;
  final bool showHandle;
  final bool includeBottomSafeArea;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        20.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) ...[
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.kBorder,
                borderRadius: BorderRadius.circular(99.r),
              ),
            ),
            SizedBox(height: 16.h),
          ],
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.kBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.kBorder.withValues(alpha: 0.7),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    gradient: AppColors.kPrimaryGradient,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.kPrimary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalItems ${totalItems == 1 ? 'item' : 'items'}',
                        style: AppFontStyle.kMulishTextStyle(
                          fontSize: 13,
                          c: AppColors.kTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Order subtotal',
                        style: AppFontStyle.kMulishTextStyle(
                          fontSize: 12,
                          c: AppColors.kTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  Helpers.formatPrice(subtotal),
                  style: AppFontStyle.kMulishTextStyle(
                    fontSize: 22,
                    c: AppColors.kPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          _CheckoutButton(
            label: buttonLabel,
            enabled: enabled,
            onPressed: onPressed,
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: AppColors.kShadow.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
        border: Border(
          top: BorderSide(color: AppColors.kBorder.withValues(alpha: 0.6)),
        ),
      ),
      child: includeBottomSafeArea
          ? SafeArea(top: false, child: content)
          : content,
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: DecoratedBox(
        decoration: enabled
            ? AppDecorations.primaryGradient(radius: 16.r)
            : BoxDecoration(
                color: AppColors.kBorder,
                borderRadius: BorderRadius.circular(16.r),
              ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(16.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppFontStyle.kMulishTextStyle(
                    fontSize: 16,
                    c: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
