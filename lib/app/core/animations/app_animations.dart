import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shared animation timings and curves for the app.
class AppAnimations {
  AppAnimations._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 480);
  static const Duration page = Duration(milliseconds: 340);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve spring = Curves.easeOutBack;

  static const Duration staggerStep = Duration(milliseconds: 55);
  static const int maxStaggerItems = 8;

  static Duration staggerDelay(int index) {
    final step = index.clamp(0, maxStaggerItems);
    return Duration(milliseconds: staggerStep.inMilliseconds * step);
  }

  static String productHeroTag(String productId) => 'product_image_$productId';
}

class AppPageTransitions {
  AppPageTransitions._();

  static const Duration duration = AppAnimations.page;

  static Transition get standard => Transition.cupertino;
  static Transition get fade => Transition.fadeIn;
  static Transition get detail => Transition.rightToLeftWithFade;
  static Transition get modal => Transition.downToUp;
}
