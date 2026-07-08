import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/auth/presentation/widgets/card_widget.dart';

import 'package:car_app/features/auth/presentation/widgets/text_field_widget.dart';
import 'package:car_app/features/cars/data/models/car_response_model.dart';
import 'package:car_app/features/home/presentation/widgets/card_car.dart';
import 'package:car_app/features/home/presentation/widgets/container_brand.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

import '../../../cars/presentation/manager/car_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();

  List<String> cars = [
    AppImage.lamborghini,
    AppImage.ferrari,
    AppImage.porsche,
    AppImage.bmw,
  ];

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
                  ),
                  CardWidget(
                    image: AppImage.rentCar,
                    title: AppStrings.rentCar,
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
                      Navigator.of(context).pushNamed('/brands_page');
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  return ContainerBrand(image: cars[index]);
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
                      context.pushNamedTransition(
                        routeName: '/cars_page',
                        type: PageTransitionType.leftToRight,
                        duration: Duration(seconds: 2),
                        curve: Curves.fastEaseInToSlowEaseOut,
                      );
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
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    CarResponseModel cars = state.cars[index];
                    return CardCar(
                      image: cars.imageUrls[0],
                      name: "${cars.brandId} ${state.cars[index].model}",
                      price: cars.price.toDouble(),
                      speed: 3.2,
                      hp: 518,
                    );
                  }),
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
