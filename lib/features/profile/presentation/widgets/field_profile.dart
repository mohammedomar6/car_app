import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_image.dart';

class FieldProfile extends StatelessWidget {
  const FieldProfile({super.key, required this.image, required this.text});

  final String image;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w,vertical: 10.h),
      width: 350.w,
      height: 82.h,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color:AppColors.miniContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(image),
            ),
          ),
          Text(text, style: TextStyle(color: Colors.white, fontSize: 15.sp)),
         Spacer(),
          Padding(
            padding:  EdgeInsets.only(right: 20),
            child: Image.asset(AppImage.arrowPro),
          ),
        ],
      ),
    );
  }
}
