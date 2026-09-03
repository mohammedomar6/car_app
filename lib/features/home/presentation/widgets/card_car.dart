import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/features/cars/presentation/widgets/container_favorite_widget.dart';
import 'package:car_app/features/home/presentation/widgets/card_details_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_image.dart';
import '../../../cars/data/models/car_response_model.dart';


class CardCar extends StatelessWidget {
  CardCar({
    super.key,
    required this.car,
    required this.name,
    required this.price,
    required this.speed,
    required this.hp,
    required this.image,
    this.onPressed,
  });
  final CarResponseModel car;
  final String name;
  final  void Function()? onPressed;
  final double price;
  final double speed;
  final int hp;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
      width: 350.w,
      height: 520.h,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
                child: image.trim().isEmpty
                    ? _imageFallback()
                    : Image.network(
                        image,
                        width: double.infinity,
                        height: 256.h,
                        errorBuilder: (context, error, stackTrace) {
                          return _imageFallback();
                        },
                        fit: BoxFit.cover,
                      ),
              ),
              Positioned(
                top: 12.h,
                right: 5.w,
                child:
               ContainerFavoriteWidget(
                 car: car,
                 iconColor: AppColors.backgroundLight,
                 radius: 25.r,
               )
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(15.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme
                      .of(
                    context,
                  )
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 18.sp),
                ),
                Text(
                  "$price\$",
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CardDetailsWidget(
                image: AppImage.speed,
                title: '${speed.toStringAsFixed(0)} km/h',
              ),
              CardDetailsWidget(
                image: AppImage.timer,
                title: 'dyn_seconds'.tr(namedArgs: {'value': '2.8'}),
              ),
              CardDetailsWidget(
                image: AppImage.energy,
                title: 'dyn_hp'.tr(namedArgs: {'value': '$hp'}),
              ),
            ],
          ),
          SizedBox(height: 30.h,),
          Center(
            child: SizedBox(

              width: 300.w,
              height: 59.h,
              child: OutlinedButton(

                onPressed: onPressed,
                child: Text('ui_102'.tr()),
              ),
            ),
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      width: double.infinity,
      height: 256.h,
      color: Colors.white.withValues(alpha: 0.035),
      alignment: Alignment.center,
      child: Icon(
        Icons.directions_car_rounded,
        size: 54.r,
        color: AppColors.secondary.withValues(alpha: 0.7),
      ),
    );
  }
}
