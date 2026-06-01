import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/auth/presentation/widgets/card_widget.dart';
import 'package:car_app/features/auth/presentation/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
              child: TextFieldWidget(
                color: AppColors.backgroundLight.withOpacity(0.05),
                label: '',
                type: TextInputType.text,
                hint: AppStrings.textFieldSearch,
                icon: AppIcon.search,
                isPassword: false,
                controller: searchController,
                validator: (p0) => null,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Row(
              children: [
                CardWidget(image: AppImage.sellCar, title: AppStrings.sellCar),
                CardWidget(image: AppImage.rentCar, title: AppStrings.rentCar),
                CardWidget(image: AppImage.finance, title: AppStrings.finance),
                CardWidget(image: AppImage.concierge, title: AppStrings.concierge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
