import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/admin/presentation/widgets/custom_ink_well_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:car_app/features/transactions/presentation/utils/transaction_route_arguments.dart';

class AdminHomeScreen extends StatelessWidget {
  AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
            ),
            delegate: SliverChildListDelegate([
              AdminMenuWidget(title: 'ui_288'.tr(), onTap: () {
                Navigator.pushNamed(context, AppRoutes.users);
              },),
              AdminMenuWidget(title: 'ui_060'.tr(), onTap: () {
                Navigator.pushNamed(context, AppRoutes.pendingCars);
              },),
              AdminMenuWidget(title: 'ui_183'.tr(), onTap: () {
                Navigator.pushNamed(context, AppRoutes.adminOrders);
              },),
              AdminMenuWidget(title: 'ui_274'.tr(), onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.transactions,
                  arguments: TransactionsScreenArguments(isAdmin: true),
                );
              },),


            ]),
          ),
        ],
      ),
    );
  }
}
