import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/theme/text_style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: AppColors.backgroundDark,
    textTheme: TextStyleTheme.textThemeDark,
    textSelectionTheme: TextSelectionThemeData(cursorColor: AppColors.textAuth),
    inputDecorationTheme: InputDecorationTheme(prefixIconColor: AppColors.textAuth,  hintStyle: TextStyleTheme.textThemeDark.bodySmall,),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(AppColors.secondary),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.r)),
        ),
        foregroundColor: WidgetStatePropertyAll(AppColors.grey),
        side: WidgetStatePropertyAll(BorderSide(color: AppColors.secondary)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        alignment: AlignmentDirectional.center,
        backgroundColor: WidgetStatePropertyAll(AppColors.secondary),
        foregroundColor: WidgetStatePropertyAll(AppColors.backgroundDark),
        iconAlignment: IconAlignment.end,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
      ),
    ),
  );
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: TextStyleTheme.textThemeLight,
  );
}
