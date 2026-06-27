import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/profile/presentation/widgets/circle_profile_widget.dart';
import 'package:car_app/features/profile/presentation/widgets/container_information_widget.dart';
import 'package:car_app/features/profile/presentation/widgets/field_profile.dart';
import 'package:car_app/features/profile/presentation/widgets/row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constant/app_colors.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.account2)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 15.h,
                    horizontal: 15.w,
                  ),
                  child: Row(
                    children: [
                      CircleProfileWidget(
                        image: "assets/image/profile/personal.png",
                        width: 100.w,
                        height: 100.h,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        "Alex Sterling",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
               RowWidget(image: AppImage.profile1, text: AppStrings.profile),
                ContainerInformationWidget(
                  image: AppImage.location,
                  text: AppStrings.location,
                  sub: "Aleppo",
                ),
                ContainerInformationWidget(
                  image: AppImage.phone,
                  text: AppStrings.phone,
                  sub: AppStrings.hintPhoneNumber,
                ),
                RowWidget(image: AppImage.security, text: AppStrings.privacySecurity),
                ContainerInformationWidget(
                  image: AppImage.profile,
                  text: AppStrings.editProfile,
                  icon: AppImage.arrowPro,
                ),
                ContainerInformationWidget(
                  image: AppImage.lock,
                  text: AppStrings.changePassword,
                  icon: AppImage.arrowPro,
                ),
                RowWidget(image: AppImage.danger, text: AppStrings.danger),
                ContainerInformationWidget(
                  image: AppImage.delete,
                  text: AppStrings.delete,
                  sub: "This action is irreversible ",
                  icon: AppImage.error,
                ),
                SizedBox(height: 50.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
