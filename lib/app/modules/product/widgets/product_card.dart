import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_o_clock/app/core/animations/app_animations.dart';
import 'package:taste_o_clock/app/core/widgets/scale_tap.dart';
import 'package:taste_o_clock/app/core/utils/image_cache_utils.dart';
import 'package:taste_o_clock/app/data/models/product_model.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_decorations.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';
import 'package:taste_o_clock/app/utils/helpers.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: AppDecorations.surfaceCard(radius: 20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: AppAnimations.productHeroTag(product.id),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20.r)),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        width: double.infinity,
                        height: 148.h,
                        fit: BoxFit.cover,
                        memCacheWidth: ImageCacheSize.memWidth(
                          context,
                          MediaQuery.sizeOf(context).width,
                        ),
                        memCacheHeight: ImageCacheSize.memHeight(context, 148.h),
                        placeholder: (_, __) => Container(
                          height: 148.h,
                          color: AppColors.kChipInactive,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 148.h,
                          color: AppColors.kChipInactive,
                          child: Icon(
                            Icons.restaurant_rounded,
                            color: AppColors.kPrimary,
                            size: 40.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        product.category,
                        style: AppFontStyle.kMulishTextStyle(
                          fontSize: 11,
                          c: AppColors.kPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              color: AppColors.kSecondary, size: 14.sp),
                          SizedBox(width: 3.w),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: AppFontStyle.kMulishTextStyle(
                              fontSize: 11,
                              c: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontStyle.kMulishTextStyle(
                        fontSize: 17,
                        c: AppColors.kTextPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontStyle.kMulishTextStyle(
                        fontSize: 13,
                        c: AppColors.kTextSecondary,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Text(
                          Helpers.formatPrice(product.price),
                          style: AppFontStyle.kMulishTextStyle(
                            fontSize: 18,
                            c: AppColors.kPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            gradient: AppColors.kPrimaryGradient,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
