import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/profile/data/models/profile_response_model.dart';
import 'package:car_app/features/profile/presentation/manager/profile_bloc.dart';
import 'package:car_app/features/profile/presentation/widgets/circle_profile_widget.dart';
import 'package:car_app/features/profile/presentation/widgets/container_information_widget.dart';
import 'package:car_app/features/profile/presentation/widgets/field_profile.dart';
import 'package:car_app/features/profile/presentation/widgets/row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constant/app_colors.dart';
import '../../../../../core/utils/secure_storage.dart';

class AccountScreen extends StatefulWidget {
  AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    context.read<ProfileBloc>().add(GetProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.account2)),
      body: CustomScrollView(
        slivers: [
      SliverToBoxAdapter(
            child: BlocBuilder<ProfileBloc, ProfileState>(
  builder: (context, state) {
    if(state is ProfileErrorState){
      return Center(child:  Text(state.message),);
    }
    else if(state is ProfileLoadingState){
      return Center(child: CircularProgressIndicator(),);
    }
    else if(state is ProfileSuccessState){
       ProfileResponseModel  profile = state.profileResponseModel;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 15.h,
              horizontal: 15.w,
            ),
            child: Row(
              children: [
                CircleProfileWidget(
                  image: "assets/image/profile/personal.png",
                  width: 100.w,
                  height: 100.h,
                ),
                SizedBox(width: 12.w),
                Text(
                  (profile.fullName ?? '').trim().isEmpty
                      ? 'app_unknown_user'.tr()
                      : profile.fullName!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          RowWidget(image: AppImage.profile1, text: AppStrings.profile),
          ContainerInformationWidget(
            image: AppImage.location,
            text: AppStrings.location,
            sub: profile.address,
          ),
          ContainerInformationWidget(
            image: AppImage.phone,
            text: AppStrings.phone,
            sub: profile.phone,
          ),
          RowWidget(image: AppImage.security, text: AppStrings.privacySecurity),
          ContainerInformationWidget(
            image: AppImage.profile,
            text: AppStrings.editProfile,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.editProfile,
                arguments: profile,
              );
            },
            icon: AppImage.arrowPro,
          ),
          ContainerInformationWidget(
            onTap: (){
              Navigator.pushNamed(context, AppRoutes.changePassword);
            },
            image: AppImage.lock,
            text: AppStrings.changePassword,
            icon: AppImage.arrowPro,
          ),
          RowWidget(image: AppImage.danger, text: AppStrings.danger),
          ContainerInformationWidget(
            image: AppImage.delete,
            onTap: () {
              _showDeleteAccountDialog(context);
            },
            text: AppStrings.delete,
            sub: 'extra_102'.tr(),
            icon: AppImage.error,
          ),
          SizedBox(height: 50.h),
        ],
      );
    }
    else {
      return SizedBox.shrink();
    }

  },
),


),
        ],
      ),
    );
  }

}
void _showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) async {
            if (state is DeleteAccountSuccessState) {
              // حذف بيانات تسجيل الدخول
              await SecureStorageService.clearSession();

              if (!context.mounted) return;

              // حذف كل الصفحات السابقة والذهاب للـ Login
              AppNavigator.replaceAll(
                context,
                AppRoutes.login,
              );
            }

            if (state is DeleteAccountErrorState) {
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DeleteAccountLoadingState) {
              return AlertDialog(
                content: SizedBox(
                  height: 80,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            return AlertDialog(
              title: Text('ui_095'.tr(),
              ),
              content: Text(
                style: TextStyle(color: AppColors.textAuth),
                'Are you sure you want to delete your account?\n\n'
                    'extra_103'.tr(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text('ui_055'.tr(),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProfileBloc>().add(
                      DeleteAccountEvent(),
                    );
                  },
                  child: Text('ui_094'.tr(),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
