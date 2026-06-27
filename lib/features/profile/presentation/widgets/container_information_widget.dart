import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_image.dart';

class ContainerInformationWidget extends StatelessWidget {
  const ContainerInformationWidget({
    super.key,
    required this.image,
     this.icon,
    required this.text,
    this.onTap,  this.sub,
  });

  final String image;
  final String? icon;
  final String text;
  final String? sub;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        // width: 350.w,
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
                  color: AppColors.miniContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Image.asset(image, color: AppColors.secondary),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(text, style:Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.backgroundLight)),
              sub!=null?  Text(sub!, style:Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grey)):SizedBox.shrink(),
              ],
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(right: 20.w),
              child:icon!=null? Image.asset(icon!):SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
