import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/cars/data/data_sources/remote_data_source_car.dart';
import 'package:car_app/features/cars/data/models/car_response_model.dart';
import 'package:car_app/features/cars/presentation/widgets/attribute_container_widget.dart';
import 'package:car_app/features/cars/presentation/widgets/car_image_carousel.dart';
import 'package:car_app/features/cars/presentation/widgets/container_favorite_widget.dart';
import 'package:car_app/features/cars/presentation/widgets/icon_container.dart';
import 'package:car_app/features/profile/presentation/widgets/technical_specs_widget.dart';
import 'package:car_app/features/orders/presentation/pages/create_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarDetails extends StatefulWidget {
  final int carId;

  CarDetails({super.key, required this.carId});

  @override
  State<CarDetails> createState() => _CarDetailsState();
}

class _CarDetailsState extends State<CarDetails> {
  late Future<CarResponseModel> _carFuture;

  @override
  void initState() {
    super.initState();
    _loadCar();
  }

  void _loadCar() {
    _carFuture = RemoteDataSourceCar().getCarById(widget.carId);
  }

  void _retry() {
    setState(_loadCar);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CarResponseModel>(
      future: _carFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            ),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          final rawMessage = snapshot.error?.toString() ?? '';
          final message = (rawMessage.trim().isEmpty ? 'extra_020'.tr() : rawMessage)
              .replaceFirst('Exception: ', '')
              .replaceFirst('FormatException: ', '');
          return Scaffold(
            appBar: AppBar(title: Text('ui_061'.tr())),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(28.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      color: AppColors.secondary,
                      size: 62.r,
                    ),
                    SizedBox(height: 16.h),
                    Text('ui_081'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 11.sp),
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: Icon(Icons.refresh_rounded),
                      label: Text('ui_275'.tr()),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return _CarDetailsContent(data: snapshot.data!);
      },
    );
  }
}

class _CarDetailsContent extends StatelessWidget {
  final CarResponseModel data;

  _CarDetailsContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(

            automaticallyImplyLeading: true,
            expandedHeight: 380.h,
            pinned: true,
            snap: true,
            floating: true,

            leadingWidth: 47.w,
            leading: Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: IconContainer(icon: AppIcon.arrowContainer,onTap: () {
                Navigator.pop(context);
              },),
            ),
            actions: [IconContainer(icon: AppIcon.share)],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.none,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.brandId.toString(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  ),
                  Text(
                    data.model,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ],
              ),

              // titlePadding: EdgeInsets.only(left: 60.w, bottom: 20.h),
              background: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
                child: CarImageCarousel(
                  imageUrls: data.imageUrls,
                  height: 400.h,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: AppColors.grey),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Text(
                          data.region.trim().isEmpty
                              ? 'extra_097'.tr()
                              : data.region,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: AppColors.grey),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "${data.price.toStringAsFixed(0)}\$",
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(
                          color: AppColors.secondary,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AttributeContainerWidget(
                            image: AppImage.speed,
                            name: AppStrings.speed,
                            value: "${data.topSpeed} km/h",
                          ),
                          AttributeContainerWidget(
                            image: AppImage.timer,
                            name: "Mileage",
                            value: "${data.mileage} km",
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AttributeContainerWidget(
                            image: AppImage.energy,
                            name: AppStrings.horsepower,
                            value: "${data.horsepower} HP",
                          ),
                          AttributeContainerWidget(
                            image: AppImage.engine,
                            name: AppStrings.engine,
                            value: "${data.cylinders} cylinders",
                          ),
                        ],
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 10.w),
                        child: Text(
                          AppStrings.description,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Text(
                         data.description.trim().isEmpty
                             ? 'extra_059'.tr()
                             : data.description,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Text(
                          AppStrings.technical,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      TechnicalSpecsWidget(
                        image: AppImage.fuelType,
                        title: AppStrings.fuelType,
                        subtitle: data.fuelType,
                      ),
                      TechnicalSpecsWidget(
                        image: AppImage.transmission,
                        title: AppStrings.spareType,
                        subtitle: data.gearType,
                      ),
                      TechnicalSpecsWidget(
                        image: AppImage.driveType,
                        title: AppStrings.driveType,
                        subtitle: data.driveType.trim().isEmpty
                            ? 'extra_064'.tr()
                            : data.driveType,
                      ),
                      TechnicalSpecsWidget(
                        image: AppImage.color,
                        title: AppStrings.color,
                        subtitle: data.color.trim().isEmpty
                            ? 'extra_064'.tr()
                            : data.color,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20.h),
                        height: 98.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          color: AppColors.w5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ContainerFavoriteWidget(
                              car: data,
                              iconColor: AppColors.secondary,
                              radius: 15.r,
                            ),
                            SizedBox(
                              width: 276.w,
                              height: 56.h,
                               child: ElevatedButton(
                                style: ButtonStyle(),
                                onPressed: data.availabilityStatus
                                            .toLowerCase() ==
                                        'sold'
                                    ? null
                                    : () {
                                  final status =
                                      data.availabilityStatus.toLowerCase();
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.createOrder,
                                    arguments: CreateOrderArguments(
                                      car: data,
                                      initialType: status.contains('rent')
                                          ? 'Rent'
                                          : 'Buy',
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      data.availabilityStatus.toLowerCase() ==
                                              'sold'
                                          ? 'Sold'
                                          : 'extra_087'.tr(),
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.headlineSmall?.copyWith(),
                                    ),
                                    SizedBox(width: 8.w),
                                    Image.asset(
                                      AppImage.energy,
                                      color: AppColors.backgroundDark,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
