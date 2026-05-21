import 'package:animate_do/animate_do.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/core/constant/gradient_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    goNext();
    super.initState();
  }

  void goNext() async {
    await Future.delayed(Duration(seconds: 3));
       Navigator.of(context).pushNamed('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.loose,
        children: [
          Image.asset(AppImage.splashBackground, fit: BoxFit.cover),

          ElasticInDown(
            child: Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.secondary),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElasticInUp(
                duration: Duration(seconds: 2),
                child: Container(
                  width: 200.w,
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: AppColors.containerBackground,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.secondary),
                    boxShadow: [
                      BoxShadow(color: AppColors.secondary, blurRadius: 15),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInDown(
                        delay: Duration(seconds: 1),
                        child: Image.asset(AppImage.logo, height: 100.h),
                      ),
                      FadeInUp(
                        delay: Duration(seconds: 1),
                        child: GradientText(AppStrings.logoText),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 130.h,
            child: FadeInUp(
              delay: Duration(seconds: 2),
              child: SpinKitWaveSpinner(
                color: AppColors.secondary,
                duration: Duration(seconds: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
