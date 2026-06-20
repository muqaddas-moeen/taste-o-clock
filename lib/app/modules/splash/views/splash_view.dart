import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/config/app_config.dart';
import 'package:taste_o_clock/app/core/widgets/fade_slide_in.dart';
import 'package:taste_o_clock/app/modules/splash/controllers/splash_controller.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_decorations.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  static const String _logoAsset = 'assets/images/app_logo.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.kBackgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeSlideIn(
                slideOffset: const Offset(0, 0.2),
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: AppDecorations.surfaceCard(radius: 28.r),
                  child: Image.asset(
                    _logoAsset,
                    width: 120.w,
                    height: 120.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 28.h),
              FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: Text(
                  AppConfig.appName,
                  style: AppFontStyle.kMulishTextStyle(
                    fontSize: 28,
                    c: AppColors.kTextPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Fresh food, delivered 24/7',
                  style: AppFontStyle.kMulishTextStyle(
                    fontSize: 14,
                    c: AppColors.kTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 36.h),
              FadeSlideIn(
                delay: const Duration(milliseconds: 280),
                child: SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.kPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
