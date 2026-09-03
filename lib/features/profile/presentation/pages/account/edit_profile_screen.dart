import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/features/profile/data/models/profile_response_model.dart';
import 'package:car_app/features/profile/presentation/manager/profile_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../auth/presentation/widgets/text_field_widget.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController fullNameController;
  late TextEditingController addressController;
  late TextEditingController phoneController;

  bool initialized = false;

  @override
  void initState() {
    super.initState();

    fullNameController = TextEditingController();
    addressController = TextEditingController();
    phoneController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!initialized) {
      final profile =
      ModalRoute.of(context)!.settings.arguments
      as ProfileResponseModel;

      fullNameController.text = profile.fullName ?? '';
      addressController.text = profile.address ?? '';
      phoneController.text = profile.phone ?? '';

      initialized = true;
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    addressController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ui_109'.tr()),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is EditProfileSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('ui_204'.tr(),
                ),
              ),
            );
context.read<ProfileBloc>().add(GetProfileEvent());
            Navigator.pop(context);

          }

          if (state is EditProfileErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.massage),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is EditProfileLoadingState;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 25.h,
            ),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  TextFieldWidget(
                    label: 'ui_125'.tr(),
                    type: TextInputType.name,
                    hint: 'extra_049'.tr(),
                    icon: Icons.person_outline,
                    isPassword: false,
                    controller: fullNameController,
                    color: Colors.transparent,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'extra_075'.tr();
                      }

                      return null;
                    },
                  ),

                  TextFieldWidget(
                    label: 'ui_013'.tr(),
                    type: TextInputType.streetAddress,
                    hint: 'extra_048'.tr(),
                    icon: Icons.location_on_outlined,
                    isPassword: false,
                    controller: addressController,
                    color: Colors.transparent,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'extra_074'.tr();
                      }

                      return null;
                    },
                  ),

                  TextFieldWidget(
                    label: 'ui_197'.tr(),
                    type: TextInputType.phone,
                    hint: 'extra_050'.tr(),
                    icon: Icons.phone_outlined,
                    isPassword: false,
                    controller: phoneController,
                    color: Colors.transparent,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'extra_076'.tr();
                      }

                      return null;
                    },
                  ),

                  SizedBox(height: 25.h),

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
                        ProfileResponseModel(
                          fullName:
                          fullNameController.text.trim(),
                          address:
                          addressController.text.trim(),
                          phone:
                          phoneController.text.trim(),
                        );

                        context.read<ProfileBloc>().add(
                          EditProfileEvent(
                            request: request,
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
                          : Text('ui_231'.tr(),
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