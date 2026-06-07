import 'package:car_app/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextStyleTheme {
  static final TextTheme textThemeLight = TextTheme(
  );
  static final TextTheme textThemeDark = TextTheme(
    displayLarge: TextStyle(
      fontWeight: FontWeight.bold,
      color: AppColors.backgroundLight,
      fontSize: 22.sp,
    ),
    displayMedium: TextStyle(
      color: AppColors.grey,
      fontSize: 14.sp,
    ),
    headlineLarge: TextStyle(
      fontWeight: FontWeight.bold,
      color: AppColors.secondary,
      fontSize: 36.sp,
    ),
    headlineSmall: TextStyle(
      color: AppColors.backgroundDark,
      fontSize: 18.sp,
    ),
    bodySmall: TextStyle(
      fontSize: 12.sp,
      color: AppColors.textAuth,
    ),
    displaySmall: TextStyle(
      fontSize:16.sp,
      color: AppColors.textFieldFont
    ),
titleLarge:TextStyle(
  fontWeight: FontWeight.w900,
  fontSize: 26.sp,
  color: AppColors.textAuth
),
    titleMedium: TextStyle(fontWeight: FontWeight.w900,
        fontSize: 22.sp,
        color: AppColors.backgroundLight),

  );
}
