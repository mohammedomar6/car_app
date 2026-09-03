import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_icon.dart';
import '../../../auth/presentation/widgets/glass_blur_widget.dart';
import '../../data/models/car_response_model.dart';
import '../../../favorites/presentation/manager/favorite_bloc.dart';
import '../../../favorites/presentation/manager/favorite_event.dart';
import '../../../favorites/presentation/manager/favorite_state.dart';

class ContainerFavoriteWidget extends StatelessWidget {
  final CarResponseModel car;
  final Color iconColor;
  final Color activeColor;
  final double radius;

  ContainerFavoriteWidget({
    super.key,
    required this.car,
    required this.iconColor,
    required this.radius,
    this.activeColor = Colors.redAccent,
  });

  @override
  Widget build(BuildContext context) {
    final carId = car.carId;
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      buildWhen: (previous, current) {
        return previous.isFavorite(carId) != current.isFavorite(carId) ||
            previous.isToggling(carId) != current.isToggling(carId) ||
            previous.status != current.status;
      },
      builder: (context, state) {
        final isFavorite = state.isFavorite(carId);
        final isInitialSync = state.status == FavoriteStatus.loading &&
            state.favoriteIds.isEmpty;
        final isLoading = state.isToggling(carId) || isInitialSync;

        return GlassBlurWidget(
          padding: 0.1.r,
          radius: radius,
          height: 50.h,
          width: 50.w,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 220),
                  width: 39.r,
                  height: 39.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFavorite
                        ? activeColor.withValues(alpha: 0.13)
                        : Colors.transparent,
                  ),
                ),
                IconButton(
                  tooltip: isFavorite
                      ? 'extra_084'.tr()
                      : 'extra_006'.tr(),
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<FavoriteBloc>().add(
                                ToggleFavoriteEvent(carId: carId, car: car),
                              );
                        },
                  icon: AnimatedSwitcher(
                    duration: Duration(milliseconds: 240),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      isFavorite ? AppIcon.favorite : AppIcon.favoriteOutLined,
                      key: ValueKey(isFavorite),
                      color: isFavorite ? activeColor : iconColor,
                      size: isFavorite ? 25.r : 24.r,
                    ),
                  ),
                ),
                if (isLoading)
                  IgnorePointer(
                    child: SizedBox(
                      width: 34.r,
                      height: 34.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.4,
                        color: isFavorite ? activeColor : AppColors.secondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
