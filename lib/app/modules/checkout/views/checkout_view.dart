import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/animations/app_animations.dart';
import 'package:taste_o_clock/app/core/widgets/fade_slide_in.dart';
import 'package:taste_o_clock/app/core/widgets/section_card.dart';
import 'package:taste_o_clock/app/data/models/user_payment_info_model.dart';
import 'package:taste_o_clock/app/modules/cart/widgets/cart_summary_bar.dart';
import 'package:taste_o_clock/app/modules/checkout/controllers/checkout_controller.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_controller.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';
import 'package:taste_o_clock/app/utils/helpers.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Checkout',
              style: AppFontStyle.kMulishTextStyle(
                fontSize: 20,
                c: AppColors.kTextPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Review and confirm your order',
              style: AppFontStyle.kMulishTextStyle(
                fontSize: 12,
                c: AppColors.kTextSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                FadeSlideIn(
                  child: SectionCard(
                    icon: Icons.location_on_outlined,
                    title: 'Delivery Address',
                    child: Text(
                      controller.deliveryAddressLabel,
                      style: AppFontStyle.kMulishTextStyle(
                        fontSize: 14,
                        c: AppColors.kTextSecondary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: SectionCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'Order Summary',
                    child: Column(
                      children: [
                        for (final item in controller.items) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.name} x${item.quantity}',
                                  style: AppFontStyle.kMulishTextStyle(
                                    fontSize: 14,
                                    c: AppColors.kTextPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                Helpers.formatPrice(item.lineTotal),
                                style: AppFontStyle.kMulishTextStyle(
                                  fontSize: 14,
                                  c: AppColors.kPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                        ],
                        Divider(color: AppColors.kBorder.withValues(alpha: 0.8)),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text(
                              'Total',
                              style: AppFontStyle.kMulishTextStyle(
                                fontSize: 15,
                                c: AppColors.kTextPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              Helpers.formatPrice(controller.subtotal),
                              style: AppFontStyle.kMulishTextStyle(
                                fontSize: 20,
                                c: AppColors.kPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 160),
                  child: SectionCard(
                    icon: Icons.payment_outlined,
                    title: 'Payment Method',
                    child: Obx(
                      () => Column(
                        children: [
                          _PaymentOptionTile(
                            title: PaymentMethod.cashOnDelivery.label,
                            subtitle: 'Pay with cash when your order arrives',
                            icon: Icons.payments_outlined,
                            value: PaymentMethod.cashOnDelivery,
                            groupValue: controller.selectedPaymentMethod.value,
                            onSelect: controller.selectPaymentMethod,
                          ),
                          SizedBox(height: 10.h),
                          _PaymentOptionTile(
                            title: 'Pay with Card (Stripe)',
                            subtitle: controller.isStripeReady
                                ? 'Secure card payment via Stripe'
                                : 'Card payments unavailable',
                            icon: Icons.credit_card_rounded,
                            value: PaymentMethod.card,
                            groupValue: controller.selectedPaymentMethod.value,
                            onSelect: controller.selectPaymentMethod,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () {
              final orderController = Get.find<OrderController>();
              final isBusy = controller.isProcessingPayment.value ||
                  orderController.isPlacingOrder.value;

              return CartSummaryBar(
                totalItems: controller.totalItems,
                subtotal: controller.subtotal,
                buttonLabel: isBusy ? 'Processing...' : 'Confirm & Pay',
                enabled: !isBusy,
                onPressed: controller.confirmAndPay,
                showHandle: false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onSelect,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final PaymentMethod value;
  final PaymentMethod groupValue;
  final ValueChanged<PaymentMethod> onSelect;

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;

    return AnimatedContainer(
      duration: AppAnimations.medium,
      curve: AppAnimations.easeOut,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.kPrimary.withValues(alpha: 0.08)
            : AppColors.kChipInactive,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isSelected ? AppColors.kPrimary : AppColors.kBorder,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelect(value),
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.kPrimary.withValues(alpha: 0.15)
                        : AppColors.kSurface,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: AppColors.kPrimary, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppFontStyle.kMulishTextStyle(
                          fontSize: 14,
                          c: AppColors.kTextPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        subtitle,
                        style: AppFontStyle.kMulishTextStyle(
                          fontSize: 12,
                          c: AppColors.kTextSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                _SelectionIndicator(isSelected: isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppAnimations.fast,
      width: 22.r,
      height: 22.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.kPrimary : AppColors.kBorder,
          width: 2,
        ),
        gradient: isSelected ? AppColors.kPrimaryGradient : null,
        color: isSelected ? null : Colors.transparent,
      ),
      child: isSelected
          ? Icon(Icons.check_rounded, size: 14.sp, color: Colors.white)
          : null,
    );
  }
}
