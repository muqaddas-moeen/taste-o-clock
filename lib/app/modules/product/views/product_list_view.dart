import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import 'package:taste_o_clock/app/core/config/app_config.dart';

import 'package:taste_o_clock/app/core/widgets/animated_appear.dart';

import 'package:taste_o_clock/app/core/widgets/fade_slide_in.dart';

import 'package:taste_o_clock/app/modules/notification/widgets/notification_icon_button.dart';

import 'package:taste_o_clock/app/modules/order/widgets/active_order_banner.dart';

import 'package:taste_o_clock/app/modules/main_shell/widgets/app_bottom_nav_bar.dart';

import 'package:taste_o_clock/app/modules/product/controllers/product_controller.dart';

import 'package:taste_o_clock/app/modules/product/widgets/category_filter_bar.dart';

import 'package:taste_o_clock/app/modules/product/widgets/offline_banner.dart';

import 'package:taste_o_clock/app/modules/product/widgets/product_card.dart';

import 'package:taste_o_clock/app/modules/product/widgets/product_search_field.dart';

import 'package:taste_o_clock/app/theme/app_colors.dart';

import 'package:taste_o_clock/app/theme/app_font_style.dart';



class ProductListView extends GetView<ProductController> {

  const ProductListView({super.key});



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.kBackground,

      appBar: AppBar(

        title: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(

              AppConfig.appName,

              style: AppFontStyle.kMulishTextStyle(

                fontSize: 20,

                c: AppColors.kTextPrimary,

                fontWeight: FontWeight.w800,

                letterSpacing: -0.3,

              ),

            ),

            Text(

              'What are you craving today?',

              style: AppFontStyle.kMulishTextStyle(

                fontSize: 12,

                c: AppColors.kTextSecondary,

                fontWeight: FontWeight.w500,

              ),

            ),

          ],

        ),

        actions: const [

          NotificationIconButton(),

        ],

      ),

      body: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const ActiveOrderBanner(),

          Obx(

            () => AnimatedAppear(

              show: controller.isOffline.value,

              child: const OfflineBanner(),

            ),

          ),

          Padding(

            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 14.h),

            child: ProductSearchField(

              initialQuery: controller.searchQuery.value,

              onChanged: controller.onSearchChanged,

              onClear: controller.clearSearch,

            ),

          ),

          Padding(

            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),

            child: Text(

              'Categories',

              style: AppFontStyle.kMulishTextStyle(

                fontSize: 15,

                c: AppColors.kTextPrimary,

                fontWeight: FontWeight.w800,

              ),

            ),

          ),

          Obx(

            () {

              final categoryNames = List<String>.from(controller.categories);

              if (categoryNames.isEmpty) {

                return const SizedBox.shrink();

              }



              return CategoryFilterBar(

                categories: categoryNames,

                selectedCategory: controller.selectedCategory.value,

                onSelected: controller.selectCategory,

              );

            },

          ),

          Padding(

            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),

            child: Text(

              'Popular dishes',

              style: AppFontStyle.kMulishTextStyle(

                fontSize: 15,

                c: AppColors.kTextPrimary,

                fontWeight: FontWeight.w800,

              ),

            ),

          ),

          Expanded(child: _buildProductList(context)),

        ],

      ),

    );

  }



  Widget _buildProductList(BuildContext context) {

    return Obx(() {

      if (controller.isLoading.value && controller.products.isEmpty) {

        return const Center(child: CircularProgressIndicator());

      }



      if (controller.products.isEmpty) {

        return Center(

          child: FadeSlideIn(

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                Icon(

                  Icons.search_off_rounded,

                  size: 56.sp,

                  color: AppColors.kTextMuted,

                ),

                SizedBox(height: 12.h),

                Text(

                  'No dishes found',

                  style: AppFontStyle.kMulishTextStyle(

                    fontSize: 16,

                    c: AppColors.kTextPrimary,

                    fontWeight: FontWeight.w700,

                  ),

                ),

                SizedBox(height: 6.h),

                Text(

                  'Try another category or search term',

                  style: AppFontStyle.kMulishTextStyle(

                    fontSize: 13,

                    c: AppColors.kTextSecondary,

                  ),

                ),

              ],

            ),

          ),

        );

      }



      return RefreshIndicator(

        onRefresh: controller.refreshProducts,

        color: AppColors.kPrimary,

        child: ListView.separated(

          controller: controller.scrollController,

          padding: EdgeInsets.fromLTRB(

            16.w,

            0,

            16.w,

            24.h + MainShellInsets.contentBottom(context),

          ),

          itemCount: controller.products.length +

              (controller.isLoadingMore.value ? 1 : 0),

          separatorBuilder: (_, __) => SizedBox(height: 16.h),

          itemBuilder: (context, index) {

            if (index >= controller.products.length) {

              return Padding(

                padding: EdgeInsets.symmetric(vertical: 16.h),

                child:

                    const Center(child: CircularProgressIndicator(strokeWidth: 2)),

              );

            }



            final product = controller.products[index];

            return StaggeredEntrance(

              key: ValueKey(product.id),

              index: index,

              child: ProductCard(

                product: product,

                onTap: () => controller.openProductDetail(product),

              ),

            );

          },

        ),

      );

    });

  }

}


