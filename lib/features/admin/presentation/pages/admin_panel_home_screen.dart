import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/features/brand/presentation/pages/brands_page.dart';
import 'package:flutter/material.dart';

import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/favorites/presentation/pages/favorite_screen.dart';
import 'package:car_app/features/home/presentation/pages/home_screen.dart';
import 'package:car_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:car_app/features/search/presentation/pages/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../main_screen/data/models/bottom_navigation_bar_model.dart';
import 'admin_home_screen.dart';


class AdminPanelHomeScreen extends StatefulWidget {
  AdminPanelHomeScreen({super.key});

  @override
  State<AdminPanelHomeScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<AdminPanelHomeScreen> {
  int _currentIndex = 0;

  List<BottomNavigationBarModel> get navigation => [
    BottomNavigationBarModel(
      title: AppStrings.home,
      icon: AppIcon.home,
      page: AdminHomeScreen(),
    ),
    BottomNavigationBarModel(
      title: AppStrings.search,
      icon: AppIcon.search,
      page: SearchScreen(),
    ),
    BottomNavigationBarModel(
      title:'ui_052'.tr(),
      icon: Icons.car_crash,
      page: BrandsPage(),
    ),
    BottomNavigationBarModel(
      title: AppStrings.profile,
      icon: AppIcon.profile,
      page: ProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(AppIcon.menu),
        title: Text(
          AppStrings.logoText,
          style: Theme
              .of(context)
              .textTheme
              .titleLarge,
        ),
        actions: [
          Image.asset(AppImage.ring),
          SizedBox(width: 10.w),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        items:
        navigation
            .map(
              (e) =>
              BottomNavigationBarItem(
                label: e.title,
                icon: Icon(e.icon),
              ),
        )
            .toList(),
      ),
      body: navigation[_currentIndex].page,
    );
  }
}
