import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/utils/image_cache_utils.dart';
import 'package:taste_o_clock/app/modules/auth/controllers/auth_controller.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.photoUrl,
    required this.initials,
    this.radius = 48,
  });

  final String? photoUrl;
  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: const BoxDecoration(
        gradient: AppColors.kPrimaryGradient,
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: radius.r,
        backgroundColor: AppColors.kSurface,
        backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
            ? CachedNetworkImageProvider(
                photoUrl!,
                maxWidth: ImageCacheSize.memWidth(context, radius * 2),
                maxHeight: ImageCacheSize.memHeight(context, radius * 2),
              )
            : null,
        child: photoUrl == null
            ? Text(
                initials,
                style: AppFontStyle.kMulishTextStyle(
                  fontSize: radius * 0.55,
                  c: AppColors.kPrimary,
                  fontWeight: FontWeight.w800,
                ),
              )
            : null,
      ),
    );
  }
}

class UserProfileCard extends StatelessWidget {
  const UserProfileCard({super.key, required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      if (user == null) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          UserAvatar(
            photoUrl: user.photoUrl,
            initials: user.initials,
          ),
          SizedBox(height: 16.h),
          Text(
            user.displayName ?? 'Guest',
            style: AppFontStyle.kMulishTextStyle(
              fontSize: 22,
              c: AppColors.kTextPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            user.email,
            style: AppFontStyle.kMulishTextStyle(
              fontSize: 14,
              c: AppColors.kTextSecondary,
            ),
          ),
        ],
      );
    });
  }
}
