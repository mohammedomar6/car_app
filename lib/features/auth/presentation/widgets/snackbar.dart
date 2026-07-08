import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AppSnackBar {
  static success(BuildContext context, String message) {
    showTopSnackBar(
      snackBarPosition: SnackBarPosition.bottom,

      Overlay.of(context),
      curve: Curves.fastEaseInToSlowEaseOut,
      CustomSnackBar.success(

        backgroundColor: Colors.black,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.8),
            offset: Offset(-4, -2),
            blurRadius: 3.r,
          ),
        ],
        icon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.miniOrangeContainer,
            ),
            width: 50.w,
            height: 50.h,
            child: Image.asset(AppImage.check),
          ),
        ),
        message: message,
      ),
    );
  }

  static error(BuildContext context, String message) {
    showTopSnackBar(
      Overlay.of(context),
      snackBarPosition: SnackBarPosition.bottom,

      CustomSnackBar.error(
          backgroundColor: Colors.black,
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.8),
              offset: Offset(-4, -2),
              blurRadius: 3.r,
            ),
          ],
          icon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.miniOrangeContainer,
              ),
              width: 50.w,
              height: 50.h,
              child: Icon(Icons.error),
            ),
          ),

          message: message),
    );
  }
}
