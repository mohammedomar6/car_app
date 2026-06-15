import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';

class ContainerProfile extends StatelessWidget {
  const ContainerProfile({super.key, required this.title, required this.number});
final String title;
final int number;
  @override
  Widget build(BuildContext context) {
    return   Container(
      height: 70.h,
      width: 170.w,
      decoration: BoxDecoration(
          color: AppColors.backgroundLight.withOpacity( 0.05),
          borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title,style: Theme.of(context).textTheme.bodySmall,),

          Text("$number",style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14.sp),),

        ],
      ),
    );
  }
}
