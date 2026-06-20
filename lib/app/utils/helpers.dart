import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';

class Helpers {
  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: AppColors.kSuccess,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: AppColors.kError,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }
}
