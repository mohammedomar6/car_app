import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/helper/image_helper.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/home/presentation/widgets/card_car.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_strings.dart';
import '../manager/favorite_bloc.dart';
import '../manager/favorite_event.dart';
import '../manager/favorite_state.dart';


class FavoriteScreen extends StatefulWidget {
  FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoriteScreen> {

  @override
  void initState() {
    super.initState();

    final favoriteBloc = context.read<FavoriteBloc>();
    if (favoriteBloc.state.status == FavoriteStatus.initial) {
      favoriteBloc.add(GetMyFavoritesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {

          // =========================
          // Loading
          // =========================

          if (state.status == FavoriteStatus.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // =========================
          // Error
          // =========================

          if (state.status == FavoriteStatus.failure) {
            return Center(
              child: Text(state.message),
            );
          }

          // =========================
          // Empty
          // =========================

          if (state.status == FavoriteStatus.success &&
              state.favorites.isEmpty) {
            return Center(
              child: Text('ui_166'.tr(),
              ),
            );
          }

          // =========================
          // Success
          // =========================

          if (state.status == FavoriteStatus.success) {
            return CustomScrollView(
              slivers: [

                // =========================
                // Title
                // =========================

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 50.h,
                      left: 10.w,
                      bottom: 20.h,
                    ),
                    child: Text('ui_118'.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                        color: AppColors.backgroundLight,
                        fontSize: 22.sp,
                      ),
                    ),
                  ),
                ),

                // =========================
                // Cars
                // =========================

                SliverList.builder(
                  itemCount: state.favorites.length,
                  itemBuilder: (context, index) {

                    final car = state.favorites[index];

                    return CardCar(
                      car: car,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.carDetails,
                          arguments: car,
                        );
                      },

                      image: ImageUrlHelper.getUrl(
                        car.imageUrls.isEmpty ? '' : car.imageUrls.first,
                      ),

                      name:
                      "${car.brandId}  ${car.model}",

                      price: car.price.toDouble(),

                      speed: car.topSpeed.toDouble(),

                      hp: car.horsepower,
                    );
                  },
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
