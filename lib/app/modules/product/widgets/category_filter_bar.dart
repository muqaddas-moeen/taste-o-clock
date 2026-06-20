import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_o_clock/app/core/animations/app_animations.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_decorations.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () => onSelected(category),
            child: AnimatedScale(
              scale: isSelected ? 1.04 : 1,
              duration: AppAnimations.fast,
              curve: AppAnimations.spring,
              child: AnimatedContainer(
                duration: AppAnimations.medium,
                curve: AppAnimations.easeOut,
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                decoration: isSelected
                    ? AppDecorations.primaryGradient(radius: 24.r)
                    : BoxDecoration(
                        color: AppColors.kChipInactive,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: AppColors.kBorder.withValues(alpha: 0.7),
                        ),
                      ),
                child: Text(
                  category,
                  style: AppFontStyle.kMulishTextStyle(
                    fontSize: 13,
                    c: isSelected ? Colors.white : AppColors.kTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
