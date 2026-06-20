import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/widgets/fade_slide_in.dart';
import 'package:taste_o_clock/app/modules/auth/controllers/auth_controller.dart';
import 'package:taste_o_clock/app/modules/auth/widgets/auth_header.dart';
import 'package:taste_o_clock/app/modules/auth/widgets/google_sign_in_button.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.kBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const FadeSlideIn(
                  slideOffset: Offset(0, 0.15),
                  child: AuthHeader(),
                ),
                SizedBox(height: 48.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 160),
                  child: Obx(
                    () => GoogleSignInButton(
                      isLoading: controller.isLoading.value,
                      onPressed: controller.signInWithGoogle,
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 280),
                  child: _buildFooter(),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Sign in with your Google account to continue',
      textAlign: TextAlign.center,
      style: AppFontStyle.kMulishTextStyle(
        fontSize: 12,
        c: AppColors.kTextMuted,
        height: 1.5,
      ),
    );
  }
}
