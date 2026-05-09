import 'package:car_app/core/constant/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.backgroundDark,
  );
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: TextTheme(displayLarge: TextStyle(color: Colors.red)),
  );
}
