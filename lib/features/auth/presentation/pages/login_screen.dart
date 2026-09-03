import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/core/utils/app_utils.dart';
import 'package:car_app/features/auth/data/models/login_request_model.dart';
import 'package:car_app/features/auth/presentation/manager/login_bloc/login_bloc.dart';
import 'package:car_app/features/auth/presentation/widgets/elevated_button_widget.dart';
import 'package:car_app/features/auth/presentation/widgets/glass_blur_widget.dart';
import 'package:car_app/features/auth/presentation/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundDark,
      body: Form(
        key: formKey,
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${state.responseModel.message} ${state.responseModel.role}',
                  ),
                ),
              );
              if (state.responseModel.role.trim().toLowerCase() == 'admin') {
                AppNavigator.replaceAll(context, AppRoutes.adminPanel);
              } else {
                AppNavigator.replaceAll(context, AppRoutes.main);
              }
            } else if (state is LoginError) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    actionsAlignment:MainAxisAlignment.start,
                    title: Text('ui_134'.tr()),
                    actions: [
                      ElevatedButtonWidget(
                        width: 100.w,
                        height: 40.h,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        label: 'ui_045'.tr(),
                      ),
                    ],
                    icon: Icon(
                      Icons.error_outlined,
                      color: AppColors.secondary,
                    ),
                  );
                },
              );
            }
          },
          builder: (context, state) {
            return Stack(
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
                    GlassBlurWidget(
                      padding: 32.r,
                      radius: 12.r,
                      height: 453.h,
                      width: 350.w,
                      child: Column(
                        children: [
                          TextFieldWidget(
                            color: AppColors.darkGrey,
                            validator: (p0) {
                              if (!AppUtils.isValidEmail(p0!)) {
                                return 'extra_037'.tr();
                              } else {
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
                              if (p0!.isEmpty) {
                                return 'extra_046'.tr();
                              } else if (p0.length < 8) {
                                return 'extra_001'.tr();
                              } else {
                                return null;
                              }
                            },
                            controller: passwordController,
                            isPassword: true,
                            label: AppStrings.password,
                            icon: AppIcon.password,
                            type: TextInputType.visiblePassword,
                            hint: AppStrings.obscure,
                          ),
                          SizedBox(height: 30.h),
                          ElevatedButtonWidget(
                            width: 234.w,
                            height: 59.h,
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                context.read<LoginBloc>().add(
                                  LogiEvent(
                                    requestModel: LoginRequestModel(
                                      email: emailController.text,
                                      password: passwordController.text,
                                    ),
                                  ),
                                );
                              }

                              // if(formKey.currentState!.validate()){
                              //
                              // }
                            },
                            label: AppStrings.signIn,
                            icon: AppIcon.arrow,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.r),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.haveAccount,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.signUp);
                            },
                            child: Text(AppStrings.createAccount),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
