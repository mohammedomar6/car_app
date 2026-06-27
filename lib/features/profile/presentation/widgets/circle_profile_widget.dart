import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CircleProfileWidget extends StatelessWidget {
  const CircleProfileWidget({super.key, required this.image, required this.height, required this.width});
final String image;
final double height;
final double width;
  @override
  Widget build(BuildContext context) {
    return  Container(
      height: height,
      width:width,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          colors: [Color(0xffFF5722), Color(0xff333535)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Padding(
          padding:  EdgeInsets.all(2.0.r),
          child: Image.asset(image,
            ),
        ),
      ),
    );
  }
}
