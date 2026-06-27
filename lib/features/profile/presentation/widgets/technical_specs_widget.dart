import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';

class TechnicalSpecsWidget extends StatelessWidget {
  const TechnicalSpecsWidget({super.key, required this.image, required this.title, required this.subtitle});
  final String image;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return  Container(margin: EdgeInsets.symmetric(horizontal: 5.w,vertical: 8.h),
        width: 370.w,
        height: 65.h,
        decoration: BoxDecoration(
            color: AppColors.w5,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color:AppColors.w5 ,
            )
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Image.asset(image),
            ),
            Text(title,style:Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.backgroundLight,
            )),
            Spacer(),
            Padding(
              padding:  EdgeInsets.all(12.r),
              child: Text(subtitle,
                style: TextStyle(
                  color: AppColors.grey),),
            ),
          ],
        )
    );
  }
}
