import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.kWarning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.kWarning.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_off_rounded, size: 18.sp, color: AppColors.kWarning),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Offline mode — showing cached menu items',
                style: AppFontStyle.kMulishTextStyle(
                  fontSize: 12,
                  c: AppColors.kTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
