import 'package:car_app/features/home/presentation/widgets/card_car.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_strings.dart';
import '../manager/car_bloc.dart';

class CarsPage extends StatefulWidget {
  const CarsPage({super.key});

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CarBloc, CarState>(
        builder: (context, state) {
          if (state is CarErrorState) {
            return Center(child: Text(state.message));
          } else if (state is CarLoadingState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is CarSuccessState) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 50.h,
                      left: 10.w,
                      bottom: 20.h,
                    ),
                    child: Text(
                      AppStrings.featureCars,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(
                        color: AppColors.backgroundLight,
                        fontSize: 22.sp,
                      ),
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: state.cars.length,
                  itemBuilder: (context, index) {
                    return CardCar(
                      image: state.cars[index].imageUrls[0],
                      name:
                          "${state.cars[index].brand}  ${state.cars[index].model}",
                      price: state.cars[index].price,
                      speed: 3.2,
                      hp: 518,
                    );
                  },
                ),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
