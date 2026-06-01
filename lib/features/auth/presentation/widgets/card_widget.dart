import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_image.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({super.key, required this.image, required this.title, this.onTap});
  final String image ;
  final String title;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.all(10.r),
            height: 75.h,
            width: 75.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              color: AppColors.backgroundLight.withOpacity(0.05),
            ),
            child: Image.asset(image),
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.backgroundLight,
          ),
        ),
      ],
    );
  }
}
