import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';

class OrderCarNavigation {
  const OrderCarNavigation._();

  static void openCarDetails(
    BuildContext context,
    int carId,
  ) {
    Navigator.pushNamed(context, AppRoutes.carDetails, arguments: carId);
  }
}
