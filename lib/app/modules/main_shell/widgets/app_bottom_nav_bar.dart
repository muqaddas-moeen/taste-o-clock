import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/animations/app_animations.dart';
import 'package:taste_o_clock/app/core/widgets/scale_tap.dart';
import 'package:taste_o_clock/app/modules/cart/controllers/cart_controller.dart';
import 'package:taste_o_clock/app/modules/main_shell/controllers/main_shell_controller.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_decorations.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const double fadeHeight = 6;
  static const double navBarInnerHeight = 50;

  /// Total height of the bottom nav overlay (blur + bar + home indicator).
  static double overlayHeight(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom;
  }

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItemData(
      icon: Icons.restaurant_menu_rounded,
      activeIcon: Icons.restaurant_menu_rounded,
      label: 'Menu',
    ),
    _NavItemData(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Orders',
    ),
    _NavItemData(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      label: 'Cart',
      showCartBadge: true,
    ),
    _NavItemData(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BlurFadeStrip(height: fadeHeight.h),
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.9, sigmaY: 0.9),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.kBackground.withValues(alpha: 0.8),
                border: Border(
                  top: BorderSide(
                    color: AppColors.kBorder.withValues(alpha: 0.45),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
                  child: Row(
                    children: List.generate(
                      _items.length,
                      (index) => Expanded(
                        child: _BottomNavItem(
                          data: _items[index],
                          isSelected: currentIndex == index,
                          onTap: () => onTap(index),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Blurs scroll content behind the nav — opacity fades in, no color wash.
class _BlurFadeStrip extends StatelessWidget {
  const _BlurFadeStrip({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.45),
                Colors.black,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: ColoredBox(color: Colors.white.withValues(alpha: 0.08)),
          ),
        ),
      ),
    );
  }
}

class MainShellInsets {
  MainShellInsets._();

  static bool get isInMainShell => Get.isRegistered<MainShellController>();

  static double contentBottom(BuildContext context) {
    if (!isInMainShell) return 0;
    return AppBottomNavBar.overlayHeight(context) + 16.h;
  }
}

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.showCartBadge = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool showCartBadge;
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.medium,
        curve: AppAnimations.easeOut,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.kPrimaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.kPrimary.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            SizedBox(height: 4.h),
            AnimatedDefaultTextStyle(
              duration: AppAnimations.fast,
              style: AppFontStyle.kMulishTextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                c: isSelected ? Colors.white : AppColors.kTextMuted,
              ),
              child: Text(data.label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final iconColor = isSelected ? Colors.white : AppColors.kTextSecondary;
    final icon = Icon(
      isSelected ? data.activeIcon : data.icon,
      size: 22.sp,
      color: iconColor,
    );

    if (!data.showCartBadge || !Get.isRegistered<CartController>()) {
      return icon;
    }

    final cartController = Get.find<CartController>();
    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          if (cartController.totalItems.value > 0)
            Positioned(
              right: -8.w,
              top: -4.h,
              child: AnimatedSwitcher(
                duration: AppAnimations.fast,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Container(
                  key: ValueKey(cartController.totalItems.value),
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.kBackground : AppColors.kPrimary,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.kPrimary.withValues(alpha: 0.2)
                          : Colors.white,
                      width: 1.5,
                    ),
                    boxShadow: AppDecorations.softShadow,
                  ),
                  constraints: BoxConstraints(minWidth: 16.w),
                  child: Text(
                    '${cartController.totalItems.value}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? AppColors.kPrimary : Colors.white,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
