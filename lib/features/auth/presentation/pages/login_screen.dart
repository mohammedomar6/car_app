import 'dart:ui';

import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/auth/presentation/widgets/elevated_button_widget.dart';
import 'package:car_app/features/auth/presentation/widgets/glass_blur_widget.dart';
import 'package:car_app/features/auth/presentation/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.asset(
            AppImage.backgroundLogin,
            fit: BoxFit.cover,
            width: double.infinity,

            height: double.infinity,
          ),
          Column(
            children: [
              SizedBox(height: 80.h),
              Text(
                AppStrings.logoText,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text(
                AppStrings.welcome,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              SizedBox(height: 40.h),
             GlassBlurWidget(height: 453.h, width: 350.w, child: Column(
               children: [
                 TextFieldWidget(
                   isPassword: false,
                   label: AppStrings.email,
                   icon: AppIcon.email,
                   type: TextInputType.emailAddress,
                   hint: AppStrings.hint,
                 ),

                 TextFieldWidget(
                   isPassword: true,
                   label: AppStrings.password,
                   icon: AppIcon.password,
                   type: TextInputType.visiblePassword,
                   hint: AppStrings.obscure,
                 ),
                 SizedBox(height: 30.h,),
                ElevatedButtonWidget(width: 234.w, height: 59.h, onPressed: () {

                }, label: AppStrings.signIn, icon: AppIcon.arrow)
               ],
             ),),
              SizedBox(height: 20.h),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 8.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.haveAccount,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/sign_up');
                      },
                      child: Text(AppStrings.createAccount),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
