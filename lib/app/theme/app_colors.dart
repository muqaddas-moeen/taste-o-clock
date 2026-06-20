import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color kPrimary = Color(0xFFFF6B00);
  static const Color kPrimaryLight = Color(0xFFFF8C42);
  static const Color kPrimaryDark = Color(0xFFE85D00);
  static const Color kSecondary = Color(0xFFFFB000);

  // Surfaces
  static const Color kBackground = Color(0xFFFAF7F4);
  static const Color kBackgroundSecondary = Color(0xFFF3EEE8);
  static const Color kSurface = Color(0xFFFFFFFF);
  static const Color kWhiteColor = Colors.white;
  static const Color kChipInactive = Color(0xFFF5F0EB);

  // Text
  static const Color kTextPrimary = Color(0xFF1A1A2E);
  static const Color kTextSecondary = Color(0xFF6B7280);
  static const Color kTextMuted = Color(0xFF9CA3AF);

  // Status
  static const Color kSuccess = Color(0xFF22C55E);
  static const Color kError = Color(0xFFEF4444);
  static const Color kWarning = Color(0xFFF59E0B);

  // Borders / shadows
  static const Color kBorder = Color(0xFFE8E2DA);
  static const Color kShadow = Color(0xFF1A1A2E);

  static const LinearGradient kPrimaryGradient = LinearGradient(
    colors: [kPrimary, kPrimaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient kBackgroundGradient = LinearGradient(
    colors: [kBackground, kBackgroundSecondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
