import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';

class AppDecorations {
  AppDecorations._();

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: AppColors.kShadow.withValues(alpha: 0.07),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: AppColors.kShadow.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static BoxDecoration surfaceCard({double? radius}) {
    return BoxDecoration(
      color: AppColors.kSurface,
      borderRadius: BorderRadius.circular(radius ?? 18.r),
      boxShadow: cardShadow,
    );
  }

  static BoxDecoration primaryGradient({double? radius}) {
    return BoxDecoration(
      gradient: AppColors.kPrimaryGradient,
      borderRadius: BorderRadius.circular(radius ?? 16.r),
      boxShadow: [
        BoxShadow(
          color: AppColors.kPrimary.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static BoxDecoration searchField({double? radius}) {
    return BoxDecoration(
      color: AppColors.kSurface,
      borderRadius: BorderRadius.circular(radius ?? 16.r),
      boxShadow: softShadow,
      border: Border.all(color: AppColors.kBorder.withValues(alpha: 0.6)),
    );
  }
}
