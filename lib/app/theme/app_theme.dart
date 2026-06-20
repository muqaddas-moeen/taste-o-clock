import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.kPrimary,
    scaffoldBackgroundColor: AppColors.kBackground,
    fontFamily: GoogleFonts.mulish().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: AppColors.kPrimary,
      onPrimary: Colors.white,
      secondary: AppColors.kSecondary,
      onSecondary: AppColors.kTextPrimary,
      surface: AppColors.kSurface,
      onSurface: AppColors.kTextPrimary,
      error: AppColors.kError,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.kBackground,
      foregroundColor: AppColors.kTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 20.w,
      iconTheme: const IconThemeData(color: AppColors.kTextPrimary),
      titleTextStyle: GoogleFonts.mulish(
        color: AppColors.kTextPrimary,
        fontSize: 20.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.mulish(
        fontSize: 28.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.kTextPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.mulish(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.kTextPrimary,
      ),
      titleMedium: GoogleFonts.mulish(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.kTextPrimary,
      ),
      bodyLarge: GoogleFonts.mulish(
        fontSize: 16.sp,
        color: AppColors.kTextPrimary,
      ),
      bodyMedium: GoogleFonts.mulish(
        fontSize: 14.sp,
        color: AppColors.kTextSecondary,
      ),
      labelLarge: GoogleFonts.mulish(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.kSurface,
      elevation: 0,
      shadowColor: AppColors.kShadow.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: AppColors.kPrimary.withValues(alpha: 0.4),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        textStyle: GoogleFonts.mulish(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.kTextPrimary,
        backgroundColor: AppColors.kSurface,
        side: const BorderSide(color: AppColors.kBorder),
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        textStyle: GoogleFonts.mulish(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.kSurface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      hintStyle: GoogleFonts.mulish(
        color: AppColors.kTextMuted,
        fontSize: 15.sp,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: AppColors.kBorder.withValues(alpha: 0.8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: AppColors.kBorder.withValues(alpha: 0.8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppColors.kPrimary, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.kBorder,
      thickness: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.kPrimary,
    ),
  );
}
