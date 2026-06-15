import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/profile/presentation/widgets/container_profile.dart';
import 'package:car_app/features/profile/presentation/widgets/field_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 30.h)),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  height: 132.h,
                  width: 132.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      colors: [Color(0xffFF5722), Color(0xff333535)],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset("assets/image/profile/personal.png"),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Alex Sterling",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.backgroundLight,
                  ),
                ),
                SizedBox(height: 30.h),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ContainerProfile(title: AppStrings.carsInGarage, number: 5),
                    ContainerProfile(
                      title: AppStrings.activeListing,
                      number: 12,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                FieldProfile(image: AppImage.garage, text: AppStrings.carsInGarage),
                FieldProfile(image: AppImage.list, text: AppStrings.list),
                FieldProfile(image: AppImage.history, text: AppStrings.history),
                FieldProfile(image: AppImage.security, text: AppStrings.security),
                FieldProfile(image: AppImage.support, text: AppStrings.support),

                SizedBox(height: 20.h),
                SizedBox(
                  height: 56.h,
                  width: 320.w,
                  child: OutlinedButton.icon(
                    icon: Image.asset(AppImage.logOut),
                    onPressed: () {},
                    label: Text(
                      AppStrings.logOut,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.textAuth,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
