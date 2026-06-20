import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_o_clock/app/core/config/app_config.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_decorations.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  static const String _logoAsset = 'assets/images/app_logo.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(18.w),
          decoration: AppDecorations.surfaceCard(radius: 28.r),
          child: Image.asset(
            _logoAsset,
            width: 88.w,
            height: 88.w,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 28.h),
        Text(
          AppConfig.appName,
          style: AppFontStyle.kMulishTextStyle(
            fontSize: 30,
            c: AppColors.kTextPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Delicious food, delivered on time',
          textAlign: TextAlign.center,
          style: AppFontStyle.kMulishTextStyle(
            fontSize: 15,
            c: AppColors.kTextSecondary,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
