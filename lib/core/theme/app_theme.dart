import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/theme/text_style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    fontFamily: 'Poppins',
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundAppbar,
      foregroundColor: AppColors.textAuth,
      elevation: 0.2.r,
      actionsPadding: EdgeInsets.all(10.h),
      shadowColor: AppColors.backgroundLight,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundAppbar,
      selectedItemColor: AppColors.textAuth,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,

      unselectedItemColor: AppColors.bottomNavigationBarItem,
    ),
    scaffoldBackgroundColor: AppColors.backgroundAppbar,
    textTheme: TextStyleTheme.textThemeDark,
    textSelectionTheme: TextSelectionThemeData(cursorColor: AppColors.textAuth),
    inputDecorationTheme: InputDecorationTheme(
      suffixIconColor: AppColors.textAuth,
      prefixIconColor: AppColors.textAuth,
      hintStyle: TextStyleTheme.textThemeDark.bodySmall,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(AppColors.secondary),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
        overlayColor: WidgetStatePropertyAll(AppColors.secondary),
        side: WidgetStatePropertyAll(
          BorderSide(
            color: AppColors.textAuth.withValues(alpha: 0.5),
            width: 0.3.w,
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(
          AppColors.backgroundLight.withValues(alpha: 0.05),
        ),
        foregroundColor: WidgetStatePropertyAll(AppColors.backgroundLight),
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
