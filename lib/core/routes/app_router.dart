import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../../features/admin/presentation/pages/admin_panel_home_screen.dart';
import '../../features/admin/presentation/pages/all_user_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/sign_up_screen.dart';
import '../../features/brand/presentation/pages/brands_page.dart';
import '../../features/cars/data/models/car_response_model.dart';
import '../../features/cars/presentation/pages/add_edit_car_screen.dart';
import '../../features/cars/presentation/pages/car_details.dart';
import '../../features/cars/presentation/pages/cars_page.dart';
import '../../features/cars/presentation/pages/pending_cars_screen.dart';
import '../../features/favorites/presentation/pages/favorite_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/main_screen/presentation/pages/main_screen.dart';
import '../../features/onbording/presentation/pages/onboarding_screen.dart';
import '../../features/orders/presentation/pages/admin_orders_screen.dart';
import '../../features/orders/presentation/pages/create_order_screen.dart';
import '../../features/orders/presentation/pages/my_orders_screen.dart';
import '../../features/orders/presentation/pages/order_details_screen.dart';
import '../../features/orders/presentation/utils/order_details_arguments.dart';
import '../../features/profile/presentation/pages/account/account_screen.dart';
import '../../features/profile/presentation/pages/account/change_password_screen.dart';
import '../../features/profile/presentation/pages/account/edit_profile_screen.dart';
import '../../features/profile/presentation/pages/garage/cars_in_garage.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/search/presentation/pages/search_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/transactions/presentation/pages/transaction_details_screen.dart';
import '../../features/transactions/presentation/pages/transaction_form_screen.dart';
import '../../features/transactions/presentation/pages/transactions_screen.dart';
import '../../features/transactions/presentation/utils/transaction_route_arguments.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static const _duration = Duration(milliseconds: 380);

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = _pageFor(settings);

    if (settings.name == AppRoutes.splash) {
      return MaterialPageRoute<dynamic>(
        builder: (_) => page,
        settings: settings,
      );
    }

    return PageTransition<dynamic>(
      child: page,
      type: _transitionFor(settings.name),
      duration: _duration,
      reverseDuration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      opaque: true,
      settings: settings,
    );
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return PageTransition<dynamic>(
      child: _NavigationErrorScreen(routeName: settings.name),
      type: PageTransitionType.fade,
      duration: _duration,
      reverseDuration: const Duration(milliseconds: 250),
      opaque: true,
      settings: settings,
    );
  }

  static PageTransitionType _transitionFor(String? routeName) {
    switch (routeName) {
      case AppRoutes.login:
      case AppRoutes.signUp:
      case AppRoutes.main:
      case AppRoutes.adminPanel:
        return PageTransitionType.fade;
      case AppRoutes.addCar:
      case AppRoutes.createOrder:
      case AppRoutes.transactionForm:
        return PageTransitionType.bottomToTop;
      default:
        return PageTransitionType.rightToLeft;
    }
  }

  static Widget _pageFor(RouteSettings settings) {
    final arguments = settings.arguments;

    switch (settings.name) {
      case AppRoutes.splash:
        return const SplashScreen();
      case AppRoutes.onboarding:
        return const OnboardingScreen();
      case AppRoutes.login:
        return LoginScreen();
      case AppRoutes.signUp:
        return SignUpScreen();
      case AppRoutes.main:
        return MainScreen();
      case AppRoutes.home:
        return HomeScreen();
      case AppRoutes.search:
        return SearchScreen();
      case AppRoutes.addCar:
        if (arguments == null) return AddEditCarScreen();
        if (arguments is CarResponseModel) {
          return AddEditCarScreen(car: arguments);
        }
        if (arguments is AddCarRouteArguments) {
          return AddEditCarScreen(
            car: arguments.car,
            initialStatus: arguments.initialStatus,
          );
        }
        return _invalidArguments(settings.name);
      case AppRoutes.profile:
        return ProfileScreen();
      case AppRoutes.favorites:
        return FavoriteScreen();
      case AppRoutes.editProfile:
        return EditProfileScreen();
      case AppRoutes.changePassword:
        return ChangePasswordScreen();
      case AppRoutes.cars:
        if (arguments == null || arguments is int) {
          return CarsPage(brandId: arguments as int?);
        }
        return _invalidArguments(settings.name);
      case AppRoutes.brands:
        return BrandsPage();
      case AppRoutes.carDetails:
        if (arguments is CarResponseModel) {
          return CarDetails(carId: arguments.carId);
        }
        if (arguments is int) return CarDetails(carId: arguments);
        return _invalidArguments(settings.name);
      case AppRoutes.garage:
        return CarsInGarage();
      case AppRoutes.account:
        return AccountScreen();
      case AppRoutes.adminPanel:
        return AdminPanelHomeScreen();
      case AppRoutes.users:
        return AllUserScreen();
      case AppRoutes.pendingCars:
        return PendingCarsScreen();
      case AppRoutes.createOrder:
        if (arguments is CreateOrderArguments) {
          return CreateOrderScreen(
            car: arguments.car,
            initialType: arguments.initialType,
          );
        }
        if (arguments is CarResponseModel) {
          return CreateOrderScreen(car: arguments);
        }
        return _invalidArguments(settings.name);
      case AppRoutes.myOrders:
        return MyOrdersScreen();
      case AppRoutes.orderDetails:
        if (arguments is OrderDetailsArguments) {
          return OrderDetailsScreen(
            orderId: arguments.orderId,
            isAdmin: arguments.isAdmin,
            focusDocuments: arguments.focusDocuments,
          );
        }
        if (arguments is int) return OrderDetailsScreen(orderId: arguments);
        return _invalidArguments(settings.name);
      case AppRoutes.adminOrders:
        return AdminOrdersScreen();
      case AppRoutes.transactions:
        if (arguments == null) return TransactionsScreen();
        if (arguments is TransactionsScreenArguments) {
          return TransactionsScreen(
            isAdmin: arguments.isAdmin,
            initialOrderId: arguments.initialOrderId,
          );
        }
        return _invalidArguments(settings.name);
      case AppRoutes.transactionForm:
        if (arguments == null) return TransactionFormScreen();
        if (arguments is TransactionFormArguments) {
          return TransactionFormScreen(
            order: arguments.order,
            transaction: arguments.transaction,
          );
        }
        return _invalidArguments(settings.name);
      case AppRoutes.transactionDetails:
        if (arguments is TransactionDetailsArguments) {
          return TransactionDetailsScreen(
            transactionId: arguments.transactionId,
            isAdmin: arguments.isAdmin,
          );
        }
        if (arguments is int) {
          return TransactionDetailsScreen(transactionId: arguments);
        }
        return _invalidArguments(settings.name);
      default:
        return _NavigationErrorScreen(routeName: settings.name);
    }
  }

  static Widget _invalidArguments(String? routeName) {
    return _NavigationErrorScreen(routeName: routeName);
  }
}

class _NavigationErrorScreen extends StatelessWidget {
  final String? routeName;

  const _NavigationErrorScreen({this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 54),
              const SizedBox(height: 16),
              Text(
                'app_navigation_error'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (routeName != null) ...[
                const SizedBox(height: 8),
                Text(routeName!, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
