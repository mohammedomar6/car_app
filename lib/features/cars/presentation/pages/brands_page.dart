import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/home/presentation/widgets/container_brand.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_image.dart';

class BrandsPage extends StatelessWidget {
  BrandsPage({super.key});

  List<String> cars = [
    AppImage.lamborghini,
    AppImage.ferrari,
    AppImage.porsche,
    AppImage.bmw,
  ];
  List<String> nameCars = ["Lamborghini", "Ferrari", "Porsche", "BMW"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 50.h, left: 20.w, right: 20.w),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Text(
                AppStrings.brands,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.backgroundLight,
                  fontSize: 24.sp,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 10.h,left: 10),
                child: Text(
                  AppStrings.subtitleBrand,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textAuth),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 30.h,),),
            SliverGrid.builder(
              itemCount: cars.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 10.r,
                crossAxisSpacing: 10.r,
                childAspectRatio: 0.9,
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                return ContainerBrand(image: cars[index],text: nameCars[index],);
              },
            ),
          ],
        ),
      ),
    );
  }
}
