import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/auth/presentation/widgets/card_widget.dart';

import 'package:car_app/features/auth/presentation/widgets/text_field_widget.dart';
import 'package:car_app/features/cars/data/models/car_response_model.dart';
import 'package:car_app/features/home/presentation/widgets/card_car.dart';
import 'package:car_app/features/home/presentation/widgets/container_brand.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helper/image_helper.dart';
import '../../../brand/presentation/manager/brands_bloc.dart';
import '../../../cars/presentation/manager/car_bloc.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
              child: TextFieldWidget(
                color: AppColors.backgroundLight.withValues(alpha: 0.05),
                label: '',
                type: TextInputType.text,
                hint: AppStrings.textFieldSearch,
                icon: AppIcon.search,
                isPassword: false,
                controller: searchController,
                validator: (p0) => null,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CardWidget(
                    image: AppImage.sellCar,
                    title: AppStrings.sellCar,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.addCar),
                  ),
                  CardWidget(
                    image: AppImage.rentCar,
                    title: AppStrings.rentCar,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.addCar,
                        arguments: const AddCarRouteArguments(
                          initialStatus: 'For Rent',
                        ),
                      );
                    },
                  ),
                  CardWidget(
                    image: AppImage.finance,
                    title: AppStrings.finance,
                  ),
                  CardWidget(
                    image: AppImage.concierge,
                    title: AppStrings.concierge,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.brands,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.brands);
                    },
                    child: Text(
                      AppStrings.viewAll,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100.h,
              child: BlocBuilder<BrandsBloc, BrandsState>(
                builder: (context, state) {
                  if (state is GetAllBrandsLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is GetAllBrandsError) {
                    return Center(child: Text(state.massage));
                  } else if (state is GetAllBrandsSuccess) {
                    if (state.brands.isEmpty) {
                      return Center(
                        child: Text('ui_053'.tr(),
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.brands.length.clamp(0, 4),
                      itemBuilder: (context, index) {
                        return ContainerBrand(
                          image:
                          ImageUrlHelper.getUrl(state.brands[index].brandLogoUrl!),
                        );
                      },
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.featureCars,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.cars);
                    },
                    child: Text(
                      AppStrings.viewAll,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<CarBloc, CarState>(
            builder: (context, state) {
              if (state is CarErrorState) {
                return SliverToBoxAdapter(
                  child: Center(child: Text(state.message)),
                );
              } else if (state is CarSuccessState) {
                if (state.cars.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(height: 60.h),
                          Text('ui_064'.tr(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((
                    context,
                    index,
                  ) {
                    CarResponseModel cars = state.cars[index];
                    return CardCar(
                      car: cars,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.carDetails,
                          arguments: cars,
                        );
                      },
                      image: ImageUrlHelper.getUrl(
                        cars.imageUrls.isEmpty ? '' : cars.imageUrls.first,
                      ),
                      name: "${cars.brandId} ${state.cars[index].model}",
                      price: cars.price.toDouble(),
                      speed: cars.topSpeed.toDouble(),
                      hp: cars.horsepower,
                    );
                  }, childCount: 1),
                );
              } else if (state is CarLoadingState) {
                return SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else {
                return SliverToBoxAdapter(child: SizedBox.shrink());
              }
            },
          ),
        ],
      ),
    );
  }
}
