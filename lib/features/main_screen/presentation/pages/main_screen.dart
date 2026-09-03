import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/favorites/presentation/pages/favorite_screen.dart';
import 'package:car_app/features/favorites/presentation/manager/favorite_bloc.dart';
import 'package:car_app/features/favorites/presentation/manager/favorite_event.dart';
import 'package:car_app/features/favorites/presentation/manager/favorite_state.dart';
import 'package:car_app/features/home/presentation/pages/home_screen.dart';
import 'package:car_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:car_app/features/search/presentation/pages/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../cars/presentation/manager/car_bloc.dart';
import '../../data/models/bottom_navigation_bar_model.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<FavoriteBloc>().add(const GetMyFavoritesEvent());
  }

  List<BottomNavigationBarModel> get navigation => [
    BottomNavigationBarModel(
      title: AppStrings.home,
      icon: AppIcon.home,
      page: HomeScreen(),
    ),
    BottomNavigationBarModel(
      title: AppStrings.search,
      icon: AppIcon.search,
      page: SearchScreen(),
    ),
    BottomNavigationBarModel(
      title: AppStrings.favorites,
      icon: AppIcon.favorite,
      page: FavoriteScreen(),
    ),
    BottomNavigationBarModel(
      title: AppStrings.profile,
      icon: AppIcon.profile,
      page: ProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoriteBloc, FavoriteState>(
      listenWhen: (previous, current) =>
          previous.toggleStatus != current.toggleStatus &&
          current.toggleStatus == FavoriteStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Scaffold(
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
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
          if (value == 0) {
            context.read<CarBloc>().add(GetAllCars());
          }
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
        body: navigation[currentIndex].page,
      ),
    );
  }
}
