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
  );
}
