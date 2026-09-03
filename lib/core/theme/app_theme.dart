import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/theme/text_style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.secondary,
      secondary: AppColors.secondary,
      surface: AppColors.containerBackground,
      onPrimary: AppColors.backgroundDark,
      onSecondary: AppColors.backgroundDark,
      onSurface: AppColors.backgroundLight,
      error: const Color(0xFFFF6B76),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: AppColors.backgroundLight.withValues(alpha: 0.12),
      ),
    );

    return ThemeData(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    primaryColor: AppColors.secondary,
    canvasColor: const Color(0xFF202222),
    disabledColor: Colors.white30,
    focusColor: AppColors.secondary.withValues(alpha: 0.18),
    hoverColor: AppColors.secondary.withValues(alpha: 0.10),
    splashColor: AppColors.secondary.withValues(alpha: 0.12),
    highlightColor: AppColors.secondary.withValues(alpha: 0.08),
    dialogTheme: DialogThemeData(
     titleTextStyle: TextStyleTheme.textThemeDark.displayLarge,
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(10),
       side: BorderSide(
         color: AppColors.secondary.withOpacity(0.4),
       ),
     ),

     shadowColor: AppColors.secondary,
     elevation: 10,
     surfaceTintColor: AppColors.containerBackground,
     backgroundColor: AppColors.containerBackground,
   ),
    fontFamily: 'Poppins',
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(  systemStatusBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,),
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
      filled: true,
      fillColor: AppColors.backgroundLight.withValues(alpha: 0.055),
      labelStyle: const TextStyle(color: Colors.white70),
      floatingLabelStyle: TextStyle(color: AppColors.secondary),
      hintStyle: const TextStyle(color: Colors.white38),
      helperStyle: const TextStyle(color: Colors.white54),
      errorStyle: const TextStyle(color: Color(0xFFFF7B85)),
      suffixIconColor: AppColors.textAuth,
      prefixIconColor: AppColors.textAuth,
      suffixStyle: const TextStyle(color: Colors.white70),
      prefixStyle: const TextStyle(color: Colors.white70),
      border: inputBorder,
      enabledBorder: inputBorder,
      disabledBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: AppColors.secondary, width: 1.3),
      ),
      errorBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFFFF6B76)),
      ),
      focusedErrorBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFFFF6B76), width: 1.3),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.secondary
            : Colors.white54,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.secondary
            : Colors.transparent,
      ),
      checkColor: WidgetStatePropertyAll(AppColors.backgroundDark),
      side: const BorderSide(color: Colors.white54),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.backgroundDark
            : Colors.white70,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.secondary
            : Colors.white24,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.secondary,
      linearTrackColor: Colors.white12,
      circularTrackColor: Colors.white12,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.containerBackground,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: AppColors.secondary,
      headerForegroundColor: AppColors.backgroundDark,
      todayForegroundColor: WidgetStatePropertyAll(AppColors.secondary),
      todayBorder: BorderSide(color: AppColors.secondary),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.containerBackground,
      modalBackgroundColor: AppColors.containerBackground,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF242727),
      contentTextStyle: const TextStyle(color: Colors.white),
      actionTextColor: AppColors.secondary,
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.06),
      selectedColor: AppColors.secondary.withValues(alpha: 0.22),
      disabledColor: Colors.white.withValues(alpha: 0.03),
      labelStyle: const TextStyle(color: Colors.white70),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      checkmarkColor: AppColors.secondary,
      side: const BorderSide(color: Colors.white12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Colors.white,
      iconColor: Colors.white70,
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
  }
  static ThemeData lightTheme = ThemeData(

    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: TextStyleTheme.textThemeLight,
  );
}
