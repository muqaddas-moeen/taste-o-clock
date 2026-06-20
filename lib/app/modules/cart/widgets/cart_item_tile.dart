import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_o_clock/app/core/utils/image_cache_utils.dart';
import 'package:taste_o_clock/app/data/models/cart_item_model.dart';
import 'package:taste_o_clock/app/modules/cart/widgets/quantity_stepper.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_decorations.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';
import 'package:taste_o_clock/app/utils/helpers.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItemModel item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: AppDecorations.surfaceCard(radius: 18.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 76.w,
              height: 76.w,
              fit: BoxFit.cover,
              memCacheWidth: ImageCacheSize.memWidth(context, 76.w),
              memCacheHeight: ImageCacheSize.memHeight(context, 76.w),
              placeholder: (_, __) => Container(
                width: 76.w,
                height: 76.w,
                color: AppColors.kChipInactive,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 76.w,
                height: 76.w,
                color: AppColors.kChipInactive,
                child: Icon(Icons.restaurant_rounded, color: AppColors.kPrimary),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.kMulishTextStyle(
                          fontSize: 15,
                          c: AppColors.kTextPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onRemove,
                      icon: Icon(Icons.delete_outline_rounded, size: 20.sp),
                      color: AppColors.kError,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  Helpers.formatPrice(item.unitPrice),
                  style: AppFontStyle.kMulishTextStyle(
                    fontSize: 13,
                    c: AppColors.kTextSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    QuantityStepper(
                      quantity: item.quantity,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                    ),
                    const Spacer(),
                    Text(
                      Helpers.formatPrice(item.lineTotal),
                      style: AppFontStyle.kMulishTextStyle(
                        fontSize: 17,
                        c: AppColors.kPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
