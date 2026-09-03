import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';

class AdminMenuWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const AdminMenuWidget({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(
        AppColors.darkGrey,
      ),
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        margin: EdgeInsets.all(20.r),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .displayLarge!
              .copyWith(
            color: AppColors.textAuth,
          ),
        ),
      ),
    );
  }
}