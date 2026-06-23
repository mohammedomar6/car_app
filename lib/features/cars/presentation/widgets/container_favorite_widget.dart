

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_icon.dart';
import '../../../auth/presentation/widgets/glass_blur_widget.dart';

class ContainerFavoriteWidget extends StatelessWidget {
  const ContainerFavoriteWidget({super.key, required this.iconColor, required this.radius});
 final Color iconColor;
 final double radius;
  @override
  Widget build(BuildContext context) {
    return  GlassBlurWidget(
      padding: 0.1.r,
      radius: radius,
      height: 50.h,
      width: 50.w,
      child: Center(
        child: Icon(
          AppIcon.favoriteOutLined,
          color: iconColor,
        ),
      ),
    );
  }
}
