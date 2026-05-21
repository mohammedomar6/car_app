import 'package:car_app/core/constant/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GradientText extends StatelessWidget {
  final String text;

  GradientText(this.text);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback:
          (bounds) => LinearGradient(
            colors: [Color(0xffff5722), Color(0xfff67d58), Color(0xffff5722)],
          ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 32.sp,
          shadows: [
            Shadow(
              color: AppColors.secondary,
              blurRadius: 10,
              offset: Offset(-2, -2),
            ),
          ],
        ),
      ),
    );
  }
}
