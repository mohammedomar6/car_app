import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_strings.dart';
import '../../../../core/helper/image_helper.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../home/presentation/widgets/card_car.dart';
import '../manager/car_bloc.dart';

class CarsPage extends StatefulWidget {
  final int? brandId;

  CarsPage({
    super.key,
    this.brandId,
  });

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {

  @override
  void initState() {
    super.initState();

    context.read<CarBloc>().add(GetAllCars());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CarBloc, CarState>(
        builder: (context, state) {

          if (state is CarErrorState) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is CarLoadingState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is CarSuccessState) {

            // ==========================================
            // FILTER CARS BY BRAND
            // ==========================================

            final cars = widget.brandId == null
                ? state.cars
                : state.cars
                .where(
                  (car) => car.brandId == widget.brandId,
            )
                .toList();

            // ==========================================
            // NO CARS
            // ==========================================

            if (cars.isEmpty) {
              return Center(
                child: Text('ui_156'.tr(),
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            // ==========================================
            // CARS
            // ==========================================

            return CustomScrollView(
              slivers: [

                // ========================================
                // TITLE
                // ========================================

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 50.h,
                      left: 10.w,
                      bottom: 20.h,
                    ),
                    child: Text(
                      AppStrings.featureCars,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                        color: AppColors.backgroundLight,
                        fontSize: 22.sp,
                      ),
                    ),
                  ),
                ),

                // ========================================
                // CARS
                // ========================================

                SliverList.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {

                    final car = cars[index];

                    return CardCar(
                      car: car,

                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.carDetails,
                          arguments: car,
                        );
                      },

                      image: ImageUrlHelper.getUrl(
                        car.imageUrls.isEmpty ? '' : car.imageUrls.first,
                      ),

                      name:
                      '${car.brandId} ${car.model}',

                      price: car.price.toDouble(),

                      speed: car.topSpeed.toDouble(),

                      hp: car.horsepower,
                    );
                  },
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
