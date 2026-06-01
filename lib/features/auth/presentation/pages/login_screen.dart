import 'dart:ui';

import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/core/utils/app_utils.dart';
import 'package:car_app/features/auth/presentation/widgets/elevated_button_widget.dart';
import 'package:car_app/features/auth/presentation/widgets/glass_blur_widget.dart';
import 'package:car_app/features/auth/presentation/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatelessWidget {
   LoginScreen({super.key});
  TextEditingController emailController=TextEditingController();
  TextEditingController passwordController=TextEditingController();
   final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundDark,
      body: Form(
        key:  formKey,
        child: Stack(
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
                   TextFieldWidget( color: AppColors.darkGrey,
                     validator: (p0) {
                     if( ! AppUtils.isValidEmail(p0!)){
                       return "Enter Email";
                     }else {
                       return null;
                     }
                     },
                     controller: emailController,

                     isPassword: false,
                     label: AppStrings.email,
                     icon: AppIcon.email,
                     type: TextInputType.emailAddress,
                     hint: AppStrings.hint,
                   ),

                   TextFieldWidget(
                     color: AppColors.darkGrey,
                     validator: (p0) {
                      if( p0!.isEmpty ){
                        return "Enter password";
                      }else if(p0.length<8){
                      return  " password less than 8";
                      }
                      else{
                      return null;}
                     },
                     controller: passwordController,
                     isPassword: true,
                     label: AppStrings.password,
                     icon: AppIcon.password,
                     type: TextInputType.visiblePassword,
                     hint: AppStrings.obscure,
                   ),
                   SizedBox(height: 30.h,),
                  ElevatedButtonWidget(width: 234.w, height: 59.h, onPressed: () {
Navigator.of(context).pushNamed("/main_screen");
                                   // if(formKey.currentState!.validate()){
                                   //
                                   // }
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
      ),
    );
  }
}
