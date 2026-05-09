import 'package:car_app/core/theme/app_theme.dart';
import 'package:car_app/features/splash/presentation/pages/splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(
    EasyLocalization(
      startLocale: Locale('en'),
      saveLocale: true,
      child: MyApp(),
      path: "assets/translation",
      supportedLocales: [Locale('en'), Locale('ar')],
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      builder: (context, child) {
        return MaterialApp(
          theme:AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          locale: context.locale,
          routes: {'/': (context) => SplashScreen()},
        );
      },
    );
  }
}
