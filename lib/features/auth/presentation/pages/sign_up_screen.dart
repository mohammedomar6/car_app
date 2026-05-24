import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/auth/presentation/widgets/glass_blur_widget.dart';
import 'package:car_app/features/auth/presentation/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/elevated_button_widget.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppImage.backgroundSignUp,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.topStart,

                    child: TextButton.icon(
                      icon: Icon(AppIcon.arrowBack),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      label: Text(
                        AppStrings.back,
                        style: Theme.of(context).textTheme.displaySmall!
                            .copyWith(color: AppColors.secondary),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: AppStrings.create,
                          style: Theme.of(
                            context,
                          ).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.backgroundLight,
                          ),
                        ),
                        TextSpan(
                          text: AppStrings.account,
                          style: Theme.of(
                            context,
                          ).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  GlassBlurWidget(
                    height: 635.h,
                    width: 358.w,
                    child: Column(
                      children: [
                        TextFieldWidget(
                          label: AppStrings.fullName,
                          type: TextInputType.text,
                          hint: AppStrings.hintName,
                          icon: AppIcon.person,
                          isPassword: false,
                        ),
                        TextFieldWidget(
                          label: AppStrings.email,
                          type: TextInputType.emailAddress,
                          hint: AppStrings.hint,
                          icon: AppIcon.email,
                          isPassword: false,
                        ),
                        TextFieldWidget(
                          label: AppStrings.phoneNumber,
                          type: TextInputType.phone,
                          hint: AppStrings.hintPhoneNumber,
                          icon: AppIcon.phone,
                          isPassword: false,
                        ),
                        TextFieldWidget(
                          label: AppStrings.password,
                          type: TextInputType.visiblePassword,
                          hint: AppStrings.obscure,
                          icon: AppIcon.password,
                          isPassword: true,
                        ),
SizedBox(height: 15.h,),
                        ElevatedButtonWidget(width: 234.w, height: 59.h, onPressed: () {

                        }, label: AppStrings.createAccount, icon: AppIcon.arrow)
                      ],
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.all(8.0.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text(AppStrings.signIn),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
