import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';

import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/core/utils/secure_storage.dart';
import 'package:car_app/features/profile/presentation/widgets/circle_profile_widget.dart';
import 'package:car_app/features/profile/presentation/widgets/container_profile.dart';
import 'package:car_app/features/profile/presentation/widgets/field_profile.dart';
import 'package:car_app/features/profile/presentation/manager/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 30.h)),
          SliverToBoxAdapter(
            child: Column(
              children: [
               CircleProfileWidget(image:"assets/image/profile/personal.png" ,height: 132.h,width: 132.w,),
                SizedBox(height: 10.h),
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    final bloc = context.read<ProfileBloc>();
                    final profile = state is ProfileSuccessState
                        ? state.profileResponseModel
                        : bloc.currentProfile;
                    final name = (profile?.fullName ?? '').trim();
                    if (state is ProfileLoadingState && profile == null) {
                      return SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    return Text(
                      name.isEmpty ? 'app_unknown_user'.tr() : name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.backgroundLight,
                      ),
                    );
                  },
                ),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ContainerProfile(title: AppStrings.carsInGarage, number: 5),
                    ContainerProfile(
                      title: AppStrings.activeListing,
                      number: 12,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                FieldProfile(
                  onTap: (){
                    Navigator.pushNamed(context, AppRoutes.garage);
                  },
                  image: AppImage.garage,
                  text: AppStrings.carsInGarage,
                ),
                FieldProfile(image: AppImage.list, text: AppStrings.list),
                FieldProfile(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.myOrders);
                  },
                  image: AppImage.history,
                  text: AppStrings.history,
                ),
                FieldProfile(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.transactions);
                  },
                  image: AppImage.list,
                  text: AppStrings.transactions,
                ),
                FieldProfile(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.account);
                  },
                  image: AppImage.profile,
                text: AppStrings.account2,
                ),
                FieldProfile(image: AppImage.support, text: AppStrings.support),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 5.h),
                  child: ListTile(
                    onTap: () => _showLanguagePicker(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    tileColor: AppColors.backgroundLight.withValues(alpha: 0.04),
                    leading: Icon(
                      Icons.language_rounded,
                      color: AppColors.secondary,
                    ),
                    title: Text('app_language'.tr()),
                    subtitle: Text(
                      context.locale.languageCode == 'ar'
                          ? 'app_arabic'.tr()
                          : 'app_english'.tr(),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16.r,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),
                SizedBox(
                  height: 56.h,
                  width: 320.w,
                  child: OutlinedButton.icon(
                    icon: Image.asset(AppImage.logOut),
                    onPressed: () {
                      showGeneralDialog(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: AlertDialog(

                              icon: Container(
                                height: 64.h,
                                width: 64.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0x33ff5722),
                                ),
                                child: Image.asset(
                                  "assets/image/profile/check.png",
                                ),
                              ),
                              title: Text('ui_304'.tr(),
                                style: TextStyle(color: AppColors.textAuth),
                              ),
                              content: Text('ui_305'.tr(),
                                style: TextStyle(color: AppColors.textAuth),
                              ),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await SecureStorageService.clearSession();
                                    if (!context.mounted) return;
                                    AppNavigator.replaceAll(
                                      context,
                                      AppRoutes.login,
                                    );
                                  },
                                  child: Text('ui_319'.tr()),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('ui_153'.tr()),
                                ),
                              ],
                            ),
                          );
                        },
                        barrierColor: Colors.black54,
                        context: context,
                      );
                    },
                    label: Text(
                      AppStrings.logOut,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.textAuth,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final selected = await showModalBottomSheet<Locale>(
      context: context,
      backgroundColor: AppColors.containerBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'app_choose_language'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 14.h),
              RadioListTile<Locale>(
                value: const Locale('ar'),
                groupValue: context.locale,
                title: Text('app_arabic'.tr()),
                onChanged: (locale) => Navigator.pop(sheetContext, locale),
              ),
              RadioListTile<Locale>(
                value: const Locale('en'),
                groupValue: context.locale,
                title: Text('app_english'.tr()),
                onChanged: (locale) => Navigator.pop(sheetContext, locale),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && selected != context.locale && context.mounted) {
      await context.setLocale(selected);
    }
  }
}
