import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class AppFonts {
  static TextStyle getAppFonts({
    required Color txtColor,
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final textStyle = GoogleFonts.lato(
      color: txtColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
    return textStyle;
  }

  static final lat24w7 = getAppFonts(
    txtColor: AppColors.primaryBlue,
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    // height: 0.8,
  );

  static final lat20w7 = getAppFonts(
    txtColor: AppColors.secondaryBlack,
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    // height: 0.8,
  );

  static final lat16w7 = getAppFonts(
    txtColor: AppColors.greys60,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    // height: 0.8,
  );

  static final lat16w6 = getAppFonts(
    txtColor: AppColors.greys87,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    // height: 0.8,
  );

  static final lat16w4 = getAppFonts(
    txtColor: AppColors.greys87,
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    // height: 0.8,
  );

  static final lat14w7greys87 = getAppFonts(
    txtColor: AppColors.greys87,
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    // height: 0.8,
  );

  static final lat14w7customBlue = getAppFonts(
    txtColor: AppColors.customBlue,
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    // height: 0.8,
  );

  static final lat14w7white = getAppFonts(
    txtColor: AppColors.appBarBackground,
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    // height: 0.8,
  );

  static final lat14w7primaryBlue = getAppFonts(
    txtColor: AppColors.primaryBlue,
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    // height: 0.8,
  );

  static final lat14w6 = getAppFonts(
    txtColor: AppColors.darkBlue,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    // height: 0.8,
  );

  static final lat14w4greys87 = getAppFonts(
    txtColor: AppColors.greys87,
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    // height: 0.8,
  );

  static final lat14w4primaryBlue = getAppFonts(
    txtColor: AppColors.primaryBlue,
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    // height: 0.8,
  );

  static final lat14w4grey40 = getAppFonts(
    txtColor: AppColors.grey40,
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    // height: 0.8,
  );

  static final lat12w4 = getAppFonts(
    txtColor: AppColors.greys87,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    // height: 0.8,
  );

  static final lat10w4 = getAppFonts(
    txtColor: AppColors.appBarBackground,
    fontSize: 10.sp,
    fontWeight: FontWeight.w400,
    // height: 0.8,
  );

  static final lat14w7 = getAppFonts(
      height: 1.429.w,
      letterSpacing: 0.5,
      fontSize: 14.sp,
      txtColor: AppColors.darkBlue,
      fontWeight: FontWeight.w700);
}
