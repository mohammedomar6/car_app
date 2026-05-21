import 'package:car_app/core/constant/app_colors.dart';

import 'package:car_app/features/onbording/data/onboarding_data.dart';
import 'package:car_app/features/onbording/presentation/widgets/onboarding_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: onboarding.length,
            itemBuilder: (context, index) {
              return OnboardingItem(
                image: onboarding[index].image,
                title: onboarding[index].title,
                subtitle: onboarding[index].subtitle,
                index: index,
                controller: controller,
              );
            },
          ),
          Positioned(
            bottom: 70.h,
            right: 10.w,
            child: SmoothPageIndicator(
              controller: controller,
              count: onboarding.length,

              effect: ExpandingDotsEffect(
                activeDotColor: AppColors.secondary,
                dotColor: AppColors.grey,
                dotHeight: 6.h,
                dotWidth: 6.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
