import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_image.dart';

class CardDetailsWidget extends StatelessWidget {
  const CardDetailsWidget({super.key, required this.image, required this.title});
final String image ;
final String title ;
  @override
  Widget build(BuildContext context) {
    return    Container(
      width: 90.w,
      height: 60.h,

      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textAuth.withValues(alpha: 0.5),width: 0.3),
        color: AppColors.backgroundLight.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),

      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image),
          Text(title,style: TextStyle(fontSize: 10.sp,color: AppColors.textAuth),)
        ],),
    );
  }
}
