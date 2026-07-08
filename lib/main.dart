import 'package:car_app/core/theme/app_theme.dart';
import 'package:car_app/features/admin/presentation/pages/admin_panel_home_screen.dart';
import 'package:car_app/features/auth/data/data_sources/remote_data_source_auth.dart';
import 'package:car_app/features/auth/presentation/manager/auth_bloc.dart';
import 'package:car_app/features/auth/presentation/manager/login_bloc/login_bloc.dart';
import 'package:car_app/features/auth/presentation/pages/login_screen.dart';
import 'package:car_app/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:car_app/features/brand/data/data_sources/remote_data_source_brand.dart';
import 'package:car_app/features/brand/presentation/manager/brands_bloc.dart';
import 'package:car_app/features/cars/data/data_sources/remote_data_source_car.dart';
import 'package:car_app/features/cars/presentation/manager/car_bloc.dart';
import 'package:car_app/features/brand/presentation/pages/brands_page.dart';
import 'package:car_app/features/cars/presentation/pages/car_details.dart';
import 'package:car_app/features/favorites/presentation/pages/favorite_screen.dart';
import 'package:car_app/features/cars/presentation/pages/cars_page.dart';

import 'package:car_app/features/onbording/presentation/pages/onboarding_screen.dart';
import 'package:car_app/features/profile/presentation/pages/account/account_screen.dart';
import 'package:car_app/features/profile/presentation/pages/garage/cars_in_garage.dart';

import 'package:car_app/features/splash/presentation/pages/splash_screen.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'features/home/presentation/pages/home_screen.dart';
import 'features/main_screen/presentation/pages/main_screen.dart';
import 'features/profile/presentation/pages/profile_screen.dart';
import 'features/search/presentation/pages/search_screen.dart';


void main() {
  runApp(
    EasyLocalization(
      startLocale: Locale('en'),
      saveLocale: true,

      path: "assets/translation",
      supportedLocales: [Locale('en'), Locale('ar')],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
       useInheritedMediaQuery: true,

      designSize: Size(390, 884),
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => AuthBloc(RemoteDataSourceAuth()),),
            BlocProvider(create: (context) => LoginBloc(RemoteDataSourceAuth()),),
            BlocProvider(create: (context) => BrandsBloc(RemoteDataSourceBrand())..add(GetAllBrandsEvent()),),
            BlocProvider(create: (context) => CarBloc(RemoteDataSourceCar())..add(GetAllCars()),)
          ],
          child: MaterialApp(
            theme:AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            debugShowCheckedModeBanner: false,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            locale: context.locale,

            routes: {
              '/': (context) => SplashScreen(),
              '/onboarding': (context) => OnboardingScreen(),
              '/login':(context)=>LoginScreen(),
              '/sign_up':(context)=>SignUpScreen(),
              '/main_screen':(context)=>MainScreen(),
              '/home_screen':(context)=>HomeScreen(),
              '/search_screen':(context)=>SearchScreen(),
              '/profile_screen':(context)=>ProfileScreen(),
              '/favorite_screen':(context)=>FavoriteScreen(),
              '/cars_page':(context)=>CarsPage(),
              '/brands_page':(context)=>BrandsPage(),
              '/car_details':(context)=>CarDetails(),
              '/cars_in_garage':(context)=>CarsInGarage(),
              '/account_screen':(context)=>AccountScreen(),
              '/admin_panel_screen':(context)=>AdminPanelHomeScreen(),

            },
          ),
        );
      },
    );
  }
}
