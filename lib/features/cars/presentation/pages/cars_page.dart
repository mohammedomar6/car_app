import 'package:car_app/features/home/presentation/widgets/card_car.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_strings.dart';

class CarsPage extends StatelessWidget {
  const CarsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:  EdgeInsets.only(top: 50.h,left: 10.w,bottom: 20.h),
                  child: Text(
                    AppStrings.featureCars,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.backgroundLight,
                      fontSize: 22.sp,
                    ),
                  ),
                ),
              ),
              SliverList.builder(itemCount: 10,itemBuilder: (context, index) {
                return CardCar(name:"Ferrari SF90 Straddle",price:223.800,speed:3.2,hp:518);
              },)
            ],
          ),
    );
  }
}
