
import 'package:car_app/core/constant/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_image.dart';

class ContainerBrand extends StatelessWidget {
  const ContainerBrand({super.key, required this.image, this.text, this.onTap});

  final String image;
  final String? text;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 7.w),
        width: 90.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: AppColors.backgroundLight.withOpacity(0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(image, width: 50.w,height: 50,fit: BoxFit.cover,),
            SizedBox(height: 10.h,),
            text != null
                ? Text(
                  text!,
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontSize: 9.sp,
                    color: AppColors.textAuth,
                  ),
                )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
