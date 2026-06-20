import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/animations/app_animations.dart';
import 'package:taste_o_clock/app/core/widgets/fade_slide_in.dart';
import 'package:taste_o_clock/app/core/utils/image_cache_utils.dart';
import 'package:taste_o_clock/app/modules/cart/widgets/quantity_stepper.dart';
import 'package:taste_o_clock/app/modules/product/controllers/product_detail_controller.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_decorations.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';
import 'package:taste_o_clock/app/utils/helpers.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 56.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Material(
            color: Colors.black.withValues(alpha: 0.45),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: Get.back,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 40.w,
                height: 40.w,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ),
          ),
        ),
        title: const SizedBox.shrink(),
      ),
      bottomNavigationBar: Obx(() {
        final product = controller.product.value;
        if (product == null || !product.isAvailable) {
          return const SizedBox.shrink();
        }

        return FadeSlideIn(
          slideOffset: const Offset(0, 0.25),
          child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          decoration: BoxDecoration(
            color: AppColors.kSurface,
            boxShadow: AppDecorations.softShadow,
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                QuantityStepper(
                  quantity: controller.quantity.value,
                  onIncrement: controller.incrementQuantity,
                  onDecrement: controller.decrementQuantity,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    height: 52.h,
                    decoration: AppDecorations.primaryGradient(radius: 16.r),
                    child: ElevatedButton(
                      onPressed: controller.addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Add to Cart • ${Helpers.formatPrice(product.price * controller.quantity.value)}',
                        style: AppFontStyle.kMulishTextStyle(
                          fontSize: 14,
                          c: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        );
      }),
      body: Obx(() {
        if (controller.isLoading.value && controller.product.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final product = controller.product.value;
        if (product == null) {
          return Center(
            child: Text(
              'Product unavailable',
              style: AppFontStyle.kMulishTextStyle(
                fontSize: 15,
                c: AppColors.kTextSecondary,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: AppAnimations.productHeroTag(product.id),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      height: 280.h,
                      fit: BoxFit.cover,
                      memCacheWidth: ImageCacheSize.memWidth(
                        context,
                        MediaQuery.sizeOf(context).width,
                      ),
                      memCacheHeight: ImageCacheSize.memHeight(context, 280.h),
                      placeholder: (_, __) => Container(
                        height: 280.h,
                        color: AppColors.kChipInactive,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 280.h,
                        color: AppColors.kChipInactive,
                        child: Icon(
                          Icons.restaurant_rounded,
                          size: 56.sp,
                          color: AppColors.kPrimary,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.kBackground.withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: Offset(0, -24.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    slideOffset: const Offset(0, 0.18),
                    child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: AppDecorations.surfaceCard(radius: 22.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: AppColors.kPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            product.category,
                            style: AppFontStyle.kMulishTextStyle(
                              fontSize: 12,
                              c: AppColors.kPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          product.name,
                          style: AppFontStyle.kMulishTextStyle(
                            fontSize: 24,
                            c: AppColors.kTextPrimary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          product.description,
                          style: AppFontStyle.kMulishTextStyle(
                            fontSize: 15,
                            c: AppColors.kTextSecondary,
                            height: 1.55,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Text(
                              Helpers.formatPrice(product.price),
                              style: AppFontStyle.kMulishTextStyle(
                                fontSize: 24,
                                c: AppColors.kPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.star_rounded, color: AppColors.kSecondary, size: 22.sp),
                            SizedBox(width: 4.w),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: AppFontStyle.kMulishTextStyle(
                                fontSize: 15,
                                c: AppColors.kTextPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      }),
    );
  }
}
