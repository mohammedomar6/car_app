import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/cars/presentation/widgets/attribute_container_widget.dart';
import 'package:car_app/features/cars/presentation/widgets/container_favorite_widget.dart';
import 'package:car_app/features/cars/presentation/widgets/icon_container.dart';
import 'package:car_app/features/profile/presentation/widgets/technical_specs_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../auth/presentation/widgets/glass_blur_widget.dart';

class CarDetails extends StatelessWidget {
  const CarDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            expandedHeight: 350.h,
            pinned: true,
            snap: true,
            floating: true,
           collapsedHeight: 110.h,
            leadingWidth: 47.w,
            leading:  Padding(
              padding:  EdgeInsets.only(left: 10.w),
              child: IconContainer(icon: AppIcon.arrowContainer),
            ),
            actions: [
              IconContainer(icon: AppIcon.share),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.none,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FERRARI",
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  ),
                  Text(
                    "SF90 STRADALE",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ],
              ),

              titlePadding: EdgeInsets.only(left: 15.w, bottom: 20.h),
              background: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.r),
                      bottomRight: Radius.circular(20.r),
                    ),
                    child: Image.asset(
                      "assets/image/home/redCar.png",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 370.h,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(

                children: [
                  Icon(Icons.location_on_outlined, color: AppColors.grey),
                  SizedBox(width: 5.w),
                  Text(
                    "Dubai Elite Showroom, UAE",
                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(color: AppColors.grey),
                  ),
                 Spacer(),
                  Text(
                    "\$525,000",
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.secondary,
                      fontSize: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 25.h)),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AttributeContainerWidget(
                      image: AppImage.speed,
                      name: AppStrings.speed,
                      value: "4.0L V8",
                    ),
                    AttributeContainerWidget(
                      image: AppImage.timer,
                      name: AppStrings.km,
                      value: "4.0L V8",
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AttributeContainerWidget(
                      image: AppImage.energy,
                      name: AppStrings.home,
                      value: "4.0L V8",
                    ),
                    AttributeContainerWidget(
                      image: AppImage.engine,
                      name: AppStrings.engine,
                      value: "4.0L V8",
                    ),
                  ],
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.description,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Welcome to the elite world of Velocity ,"
                    "Your journey begins now Welcome to the elite world of "
                    "Velocity Your journey begins now.",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Text(
                AppStrings.technical,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child:Column(
              children: [
                TechnicalSpecsWidget(image: AppImage.fuelType, title: AppStrings.fuelType, subtitle: "Hybrid PHEV"),
                TechnicalSpecsWidget(image: AppImage.transmission, title: AppStrings.spareType, subtitle: "8-speed Dual-Clutch"),
                TechnicalSpecsWidget(image: AppImage.driveType, title: AppStrings.driveType, subtitle: "All-Wheel Drive (AWD)"),
                TechnicalSpecsWidget(image: AppImage.color, title: AppStrings.color, subtitle: "Rosso Corsa"),
              ],
            )

          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 20.h,),
              height: 98.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: AppColors.w5
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
               ContainerFavoriteWidget(iconColor: AppColors.secondary, radius: 15.r),
                  SizedBox(
                    width: 276.w,
                    height: 56.h,
                    child: ElevatedButton(style: ButtonStyle(

                    ),onPressed: (){}, child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Reserve Now",style:Theme.of(context).textTheme.headlineSmall?.copyWith(

                        )
                        ),
                        SizedBox(width: 8.w,),
                        Image.asset(AppImage.energy,color: AppColors.backgroundDark,)
                      ],
                    )),
                  )
                  
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
