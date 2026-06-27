import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RowWidget extends StatelessWidget {
  const RowWidget({super.key, required this.image, required this.text});
final String image;
final String text;

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 20.w,
      ),
      child: Row(
        children: [
          Image.asset(image,color: AppColors.textAuth,),
          SizedBox(width: 10.w),
          Text(
           text,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
