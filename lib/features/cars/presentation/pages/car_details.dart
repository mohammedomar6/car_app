import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/cars/presentation/widgets/attribute_container_widget.dart';
import 'package:car_app/features/cars/presentation/widgets/icon_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarDetails extends StatelessWidget {
  const CarDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350.h,
            actions: [
              IconContainer(icon: AppIcon.arrowContainer),
              Spacer(),
              IconContainer(icon: AppIcon.share),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: SizedBox(
                height: 42.h,
                child: Column(
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
              ),
              titlePadding: EdgeInsets.only(left: 15.w, bottom: 20.h),
              background: SizedBox(
                child: Column(
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
                      fontSize: 20,
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
                  SizedBox(height: 8.h,),
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
              child: Text(AppStrings.technical,style: Theme.of(context).textTheme.labelMedium,),
            ),
          )
        ],
      ),
    );
  }
}
