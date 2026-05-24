import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';

class GlassBlurWidget extends StatelessWidget {
  const GlassBlurWidget({super.key, required this.height, required this.width, required this.child});
 final double height;
 final double width;
 final Widget child;




  @override
  Widget build(BuildContext context) {
    return  ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(32.r),
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight.withAlpha(15),
          ),
          child: child
        ),
      ),
    );
  }
}
