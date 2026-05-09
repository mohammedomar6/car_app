import 'package:animate_do/animate_do.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElasticInLeft(
              child:  Image.asset(AppImage.logo, width: 220.w),
              duration: const Duration(seconds: 2),
              delay: const Duration(seconds: 0),
              curve: Curves.bounceIn,
            ),
            ElasticInRight(
              curve: Curves.bounceIn,
              duration: Duration(seconds: 2),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: AppStrings.logoText1,
                      style: Theme.of(context).textTheme.displayLarge
                    ),
                    TextSpan(
                      text: AppStrings.logoText2,
                      style: TextStyle(
                        color: Color(0xffa41f1f),
                        fontSize: 35.sp,

                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
