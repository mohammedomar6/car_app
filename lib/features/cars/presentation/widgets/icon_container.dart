import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';

class IconContainer extends StatelessWidget {
  const IconContainer({super.key, required this.icon, this.onTap});
 final IconData icon;
 final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40.h,
        width: 40.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.w5,
        ),
        child: Icon(icon,color: AppColors.backgroundLight,),
      ),
    );
  }
}
