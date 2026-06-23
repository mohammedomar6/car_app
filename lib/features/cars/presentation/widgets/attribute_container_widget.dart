import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';

class AttributeContainerWidget extends StatelessWidget {
  const AttributeContainerWidget({
    super.key,
    required this.image,
    required this.name,
    required this.value,
  });

  final String image;

  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.r),
      width: 167.w,
      height: 110.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.w5,
        border: Border.all(
          color:AppColors.w5 ,
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(image),
          Text(
            name,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.backgroundLight,
            ),
          ),
        ],
      ),
    );
  }
}
