import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_image.dart';
import '../../../../core/constant/app_strings.dart';
import '../../data/onboarding_data.dart';

class OnboardingItem extends StatelessWidget {
  const OnboardingItem({super.key, required this.image, required this.title, required this.subtitle, required this.index, required this.controller});
final String image ;
final String title ;
final String subtitle ;
final int index ;
final PageController controller ;
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(image, fit: BoxFit.cover),
         Container(color: AppColors.black45),
        if (index != onboarding.length - 1)
           Positioned(
            top: 20.h,
            right: 10.w,
            child: TextButton(
              style: Theme.of(
                context,
              ).textButtonTheme.style?.copyWith(
                foregroundColor: WidgetStatePropertyAll(
                  AppColors.grey,
                ),
              ),
              onPressed: () {
                controller.jumpToPage(onboarding.length - 1);
              },
              child: Text(AppStrings.skip),
            ),
          ),

         Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 225.h,
            decoration: BoxDecoration(
              color: AppColors.black80,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(25.r),
                topLeft: Radius.circular(25.r),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: 10.h,
                left: 15.w,
                right: 15.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(AppImage.line),
                  SizedBox(height: 15.h),
                  RichText(

                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style:
                          Theme.of(
                            context,
                          ).textTheme.displayLarge,
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                   subtitle,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  SizedBox(height: 15.h),

                  Align(
                    alignment: Alignment.centerLeft,
                    child:
                    index != onboarding.length - 1
                        ? TextButton(
                      onPressed: () {
                        controller.nextPage(
                          duration: Duration(seconds: 1),
                          curve: Curves.decelerate,
                        );
                      },
                      child: Text(AppStrings.next),
                    )
                        : OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(AppStrings.start),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );;
  }
}
