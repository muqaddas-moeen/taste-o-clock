import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';

abstract class AppFontStyle {
  static TextStyle kMulishTextStyle({
    double? fontSize,
    Color? c,
    FontWeight? fontWeight,
    TextDecoration? textDecoration,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.mulish(
      color: c ?? AppColors.kWhiteColor,
      fontSize: fontSize?.sp ?? 12.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: letterSpacing,
      height: height,
      decoration: textDecoration ?? TextDecoration.none,
    );
  }
}
