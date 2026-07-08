import 'dart:ui';

import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/core/utils/secure_storage.dart';
import 'package:car_app/features/profile/presentation/widgets/circle_profile_widget.dart';
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
               CircleProfileWidget(image:"assets/image/profile/personal.png" ,height: 132.h,width: 132.w,),
                SizedBox(height: 10.h),
                Text(
                  "Alex Sterling",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.backgroundLight,
                  ),
                ),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ContainerProfile(title: AppStrings.carsInGarage, number: 5),
                    ContainerProfile(
                      title: AppStrings.activeListing,
                      number: 12,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                FieldProfile(
                  onTap: (){
                    Navigator.pushNamed(context, "/cars_in_garage");
                  },
                  image: AppImage.garage,
                  text: AppStrings.carsInGarage,
                ),
                FieldProfile(image: AppImage.list, text: AppStrings.list),
                FieldProfile(image: AppImage.history, text: AppStrings.history),
                FieldProfile(
                  onTap: () {
                    Navigator.pushNamed(context, '/account_screen');
                  },
                  image: AppImage.profile,
                text: AppStrings.account2,
                ),
                FieldProfile(image: AppImage.support, text: AppStrings.support),

                SizedBox(height: 20.h),
                SizedBox(
                  height: 56.h,
                  width: 320.w,
                  child: OutlinedButton.icon(
                    icon: Image.asset(AppImage.logOut),
                    onPressed: () {
                      showGeneralDialog(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: AlertDialog(

                              icon: Container(
                                height: 64.h,
                                width: 64.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0x33ff5722),
                                ),
                                child: Image.asset(
                                  "assets/image/profile/check.png",
                                ),
                              ),
                              title: Text(
                                "Welcome Back!",
                                style: TextStyle(color: AppColors.textAuth),
                              ),
                              content: Text(
                                "Welcome to the elite world of Velocity.Your journey begins now.",
                                style: TextStyle(color: AppColors.textAuth),
                              ),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await SecureStorageService.deleteToken();
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/login',
                                      (route) => false,
                                    );
                                  },
                                  child: Text("yes"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("No"),
                                ),
                              ],
                            ),
                          );
                        },
                        barrierColor: Colors.black54,
                        context: context,
                      );
                    },
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
