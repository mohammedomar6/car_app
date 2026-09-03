import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/features/profile/data/models/change_password_request_model.dart';
import 'package:car_app/features/profile/presentation/manager/profile_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../auth/presentation/widgets/text_field_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final formKey = GlobalKey<FormState>();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ui_067'.tr()),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('ui_186'.tr(),
                ),
              ),
            );
           context.read<ProfileBloc>().add(GetProfileEvent());
            Navigator.pop(context);
          }

          if (state is ChangePasswordErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading =
          state is ChangePasswordLoadingState;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 25.h,
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  Center(
                    child: Icon(
                      Icons.lock_outline,
                      size: 70.sp,
                      color: AppColors.textAuth,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  Center(
                    child: Text('ui_069'.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 35.h),

                  TextFieldWidget(
                    label: 'ui_092'.tr(),
                    type: TextInputType.visiblePassword,
                    hint: 'extra_042'.tr(),
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: oldPasswordController,
                    color: Colors.transparent,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'extra_072'.tr();
                      }

                      return null;
                    },
                  ),

                  TextFieldWidget(
                    label: 'ui_151'.tr(),
                    type: TextInputType.visiblePassword,
                    hint: 'extra_045'.tr(),
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: newPasswordController,
                    color: Colors.transparent,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'extra_073'.tr();
                      }

                      if (value.length < 6) {
                        return 'extra_067'.tr();
                      }

                      return null;
                    },
                  ),

                  TextFieldWidget(
                    label: 'ui_075'.tr(),
                    type: TextInputType.visiblePassword,
                    hint: 'extra_030'.tr(),
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: confirmPasswordController,
                    color: Colors.transparent,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'extra_071'.tr();
                      }

                      if (value != newPasswordController.text) {
                        return 'extra_068'.tr();
                      }

                      return null;
                    },
                  ),

                  SizedBox(height: 30.h),

                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                        if (!formKey.currentState!
                            .validate()) {
                          return;
                        }

                        final request =
                        ChangePasswordRequestModel(
                          oldPassword:
                          oldPasswordController.text
                              .trim(),
                          newPassword:
                          newPasswordController.text
                              .trim(),

                        );

                        context
                            .read<ProfileBloc>()
                            .add(
                          ChangePasswordEvent(
                            changePasswordRequestModel:
                            request,
                          ),
                        );
                      },
                      child: isLoading
                          ? SizedBox(
                        width: 22.w,
                        height: 22.h,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : Text('ui_067'.tr(),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}