import 'dart:ui';
import 'package:flutter/cupertino.dart';
import '../../../../core/constant/app_colors.dart';

class GlassBlurWidget extends StatelessWidget {
  const GlassBlurWidget({super.key, required this.height, required this.width, required this.child, required this.radius, required this.padding});
 final double height;
 final double width;
 final Widget child;
 final double radius;
 final double padding;




  @override
  Widget build(BuildContext context) {
    return  ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.all(padding),
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight.withAlpha(15),
          ),
          child: Center(child: child)
        ),
      ),
    );
  }
}
