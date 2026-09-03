import 'package:car_app/core/theme/app_theme.dart';
import 'package:car_app/core/routes/app_router.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/admin/data/data_sources/remote_data_source_admin.dart';
import 'package:car_app/features/admin/presentation/manager/approve_car/approve_car_bloc.dart';
import 'package:car_app/features/admin/presentation/manager/users/users_bloc.dart';
import 'package:car_app/features/auth/data/data_sources/remote_data_source_auth.dart';
import 'package:car_app/features/auth/presentation/manager/auth_bloc.dart';
import 'package:car_app/features/auth/presentation/manager/login_bloc/login_bloc.dart';
import 'package:car_app/features/brand/data/data_sources/remote_data_source_brand.dart';
import 'package:car_app/features/brand/presentation/manager/brands_bloc.dart';
import 'package:car_app/features/cars/data/data_sources/remote_data_source_car.dart';
import 'package:car_app/features/cars/presentation/manager/car_bloc.dart';
import 'package:car_app/features/cars/presentation/manager/pending_cars_bloc.dart';
import 'package:car_app/features/favorites/data/data_sources/favorite_remote_data_source.dart';
import 'package:car_app/features/favorites/presentation/manager/favorite_bloc.dart';
import 'package:car_app/features/orders/data/data_sources/order_remote_data_source.dart';
import 'package:car_app/features/orders/presentation/manager/order_bloc.dart';
import 'package:car_app/features/transactions/data/data_sources/transaction_remote_data_source.dart';
import 'package:car_app/features/transactions/presentation/manager/transaction_bloc.dart';
import 'package:car_app/features/profile/data/data_sources/remote_data_source_profile.dart';
import 'package:car_app/features/profile/presentation/manager/profile_bloc.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      startLocale: const Locale('en'),
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      saveLocale: true,
      path: "assets/translation",
      supportedLocales: const [Locale('en'), Locale('ar')],
      child: const MyApp(),
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
        final fontFamily =
            context.locale.languageCode == 'ar' ? 'Alexandria' : 'Poppins';
        final lightTheme = AppTheme.lightTheme;
        final darkTheme = AppTheme.darkTheme;
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => AuthBloc(RemoteDataSourceAuth())),
            BlocProvider(create: (context) => ApproveCarBloc(remoteDataSourceAdmin: RemoteDataSourceAdmin())),
            BlocProvider(
              create:
                  (context) => FavoriteBloc(
                    remoteDataSource: FavoriteRemoteDataSourceImpl(),
                  ),
            ),
            BlocProvider(
              create:
                  (context) => PendingCarsBloc(
                    remoteDataSourceAdmin: RemoteDataSourceAdmin(),
                  ),
            ),
            BlocProvider(
              create: (context) => LoginBloc(RemoteDataSourceAuth()),
            ),
            BlocProvider(
              create:
                  (context) =>
                      BrandsBloc(RemoteDataSourceBrand())
                        ..add(GetAllBrandsEvent()),
            ),
            BlocProvider(
              create:
                  (context) =>
                      CarBloc(RemoteDataSourceCar())..add(GetAllCars()),
            ),
            BlocProvider(
              create:
                  (context) =>
                      ProfileBloc(RemoteDataSourceProfile())
                        ..add(GetProfileEvent()),
            ),
            BlocProvider(
              create: (context) => UsersBloc(RemoteDataSourceAdmin()),
            ),
            BlocProvider(
              create: (context) => OrderBloc(OrderRemoteDataSource()),
            ),
            BlocProvider(
              create: (context) =>
                  TransactionBloc(TransactionRemoteDataSource()),
            ),
          ],
          child: MaterialApp(
            theme: lightTheme.copyWith(
              textTheme: lightTheme.textTheme.apply(fontFamily: fontFamily),
            ),
            darkTheme: darkTheme.copyWith(
              textTheme: darkTheme.textTheme.apply(fontFamily: fontFamily),
              primaryTextTheme:
                  darkTheme.primaryTextTheme.apply(fontFamily: fontFamily),
            ),
            themeMode: ThemeMode.dark,
            debugShowCheckedModeBanner: false,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            locale: context.locale,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
            onUnknownRoute: AppRouter.onUnknownRoute,
          ),
        );
      },
    );
  }
}
