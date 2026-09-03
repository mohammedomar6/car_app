import 'package:flutter/material.dart';

import '../../features/cars/data/models/car_response_model.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signUp = '/sign_up';
  static const main = '/main_screen';
  static const home = '/home_screen';
  static const search = '/search_screen';
  static const addCar = '/add_car';
  static const profile = '/profile_screen';
  static const favorites = '/favorite_screen';
  static const editProfile = '/editProfile';
  static const changePassword = '/changePassword';
  static const cars = '/cars_page';
  static const brands = '/brands_page';
  static const carDetails = '/car_details';
  static const garage = '/cars_in_garage';
  static const account = '/account_screen';
  static const adminPanel = '/admin_panel_screen';
  static const users = '/allUser';
  static const pendingCars = '/pending_cars';
  static const createOrder = '/create_order';
  static const myOrders = '/my_orders';
  static const orderDetails = '/order_details';
  static const adminOrders = '/admin_orders';
  static const transactions = '/transactions';
  static const transactionForm = '/transaction_form';
  static const transactionDetails = '/transaction_details';
}

class AddCarRouteArguments {
  final CarResponseModel? car;
  final String initialStatus;

  const AddCarRouteArguments({
    this.car,
    this.initialStatus = 'Available',
  });
}

abstract final class AppNavigator {
  static Future<dynamic> replaceAll(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<dynamic>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}
