import 'package:car_app/core/constant/app_colors.dart';
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

              ],
            ),
          ),
        ],
      ),
    );
  }
}
