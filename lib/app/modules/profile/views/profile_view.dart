import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/widgets/fade_slide_in.dart';
import 'package:taste_o_clock/app/core/widgets/section_card.dart';
import 'package:taste_o_clock/app/data/models/user_payment_info_model.dart';
import 'package:taste_o_clock/app/modules/auth/controllers/auth_controller.dart';
import 'package:taste_o_clock/app/modules/auth/widgets/user_profile_card.dart';
import 'package:taste_o_clock/app/modules/main_shell/widgets/app_bottom_nav_bar.dart';
import 'package:taste_o_clock/app/modules/profile/controllers/profile_controller.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_decorations.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  AuthController get _authController => Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Profile',
              style: AppFontStyle.kMulishTextStyle(
                fontSize: 20,
                c: AppColors.kTextPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Manage your account details',
              style: AppFontStyle.kMulishTextStyle(
                fontSize: 12,
                c: AppColors.kTextSecondary,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16.w,
          16.h,
          16.w,
          MainShellInsets.contentBottom(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeSlideIn(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                decoration: AppDecorations.surfaceCard(radius: 22.r),
                child: UserProfileCard(controller: _authController),
              ),
            ),
            SizedBox(height: 20.h),
            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: SectionCard(
                icon: Icons.person_outline_rounded,
                title: 'Basic Details',
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Phone',
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      hint: 'Enter phone number',
                    ),
                    SizedBox(height: 14.h),
                    Obx(
                      () => GradientPrimaryButton(
                        label: 'Save Details',
                        isLoading: controller.isSavingDetails.value,
                        onPressed: controller.isSavingDetails.value
                            ? null
                            : controller.saveBasicDetails,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            FadeSlideIn(
              delay: const Duration(milliseconds: 140),
              child: SectionCard(
                icon: Icons.location_on_outlined,
                title: 'Delivery Location',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(() {
                      final location = _authController.user.value?.location;
                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.kChipInactive,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          location?.formattedAddress ??
                              'No location saved yet. Use GPS or enter an address.',
                          style: AppFontStyle.kMulishTextStyle(
                            fontSize: 13,
                            c: AppColors.kTextSecondary,
                            height: 1.45,
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 12.h),
                    Obx(
                      () => OutlinedButton.icon(
                        onPressed: controller.isUpdatingLocation.value
                            ? null
                            : controller.useCurrentLocation,
                        icon: controller.isUpdatingLocation.value
                            ? SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location_rounded),
                        label: Text(
                          controller.isUpdatingLocation.value
                              ? 'Fetching location...'
                              : 'Use Current Location',
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _LabeledField(
                      label: 'Address',
                      controller: controller.addressLineController,
                      hint: 'Street, building, area',
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'City',
                            controller: controller.cityController,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _LabeledField(
                            label: 'State',
                            controller: controller.stateController,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    _LabeledField(
                      label: 'Postal Code',
                      controller: controller.postalCodeController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 14.h),
                    Obx(
                      () => GradientPrimaryButton(
                        label: 'Save Location',
                        isLoading: controller.isSavingLocation.value,
                        onPressed: controller.isSavingLocation.value
                            ? null
                            : controller.saveLocation,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: SectionCard(
                icon: Icons.payment_outlined,
                title: 'Payment Info',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(
                      () => DropdownButtonFormField<PaymentMethod>(
                        value: controller.selectedPaymentMethod.value,
                        decoration: InputDecoration(
                          labelText: 'Payment Method',
                          filled: true,
                          fillColor: AppColors.kChipInactive,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: PaymentMethod.values
                            .map(
                              (method) => DropdownMenuItem(
                                value: method,
                                child: Text(method.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedPaymentMethod.value = value;
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Obx(
                      () => controller.selectedPaymentMethod.value ==
                              PaymentMethod.card
                          ? Column(
                              children: [
                                _LabeledField(
                                  label: 'Card Holder Name',
                                  controller: controller.cardHolderController,
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _LabeledField(
                                        label: 'Last 4 Digits',
                                        controller:
                                            controller.cardLast4Controller,
                                        keyboardType: TextInputType.number,
                                        maxLength: 4,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: _LabeledField(
                                        label: 'Brand',
                                        controller:
                                            controller.cardBrandController,
                                        hint: 'Visa, Mastercard',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14.h),
                              ],
                            )
                          : Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColors.kChipInactive,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                'Pay with cash when your order arrives.',
                                style: AppFontStyle.kMulishTextStyle(
                                  fontSize: 13,
                                  c: AppColors.kTextSecondary,
                                ),
                              ),
                            ),
                    ),
                    Obx(
                      () => GradientPrimaryButton(
                        label: 'Save Payment Info',
                        isLoading: controller.isSavingPayment.value,
                        onPressed: controller.isSavingPayment.value
                            ? null
                            : controller.savePaymentInfo,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            FadeSlideIn(
              delay: const Duration(milliseconds: 260),
              child: OutlinedButton.icon(
                onPressed: controller.signOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.kError,
                  side: BorderSide(
                    color: AppColors.kError.withValues(alpha: 0.5),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.maxLength,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.kChipInactive,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.kPrimary, width: 1.5),
        ),
        counterText: '',
      ),
    );
  }
}
