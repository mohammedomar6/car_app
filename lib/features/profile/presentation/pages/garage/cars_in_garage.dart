import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/cars/data/models/car_response_model.dart';
import 'package:car_app/features/home/presentation/widgets/card_car.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../cars/presentation/manager/car_bloc.dart';

class CarsInGarage extends StatefulWidget {
  const CarsInGarage({super.key});

  @override
  State<CarsInGarage> createState() => _CarsInGarageState();
}

class _CarsInGarageState extends State<CarsInGarage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<CarBloc>().add(GetMyCars());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 50.w,
        title: Text(AppStrings.carsInGarage),
        leading: Icon(AppIcon.arrowBack),
      ),
      body: CustomScrollView(
        slivers: [
          BlocBuilder<CarBloc, CarState>(
            builder: (context, state) {
              if (state is MyCarsLoadingState) {
                return SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              } else if (state is MyCarsErrorState) {
                return SliverToBoxAdapter(child: Center(child: Text(state.massage)));
              } else if (state is MyCarsSuccessState) {
                if(state.myCars.isEmpty){
                  return SliverToBoxAdapter(child: Center(child: Text('No Car'),),);
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: state.myCars.length,
                    (context, index) {
                      CarResponseModel car=state.myCars[index];
                      return CardCar(
                        onPressed: () {
                          Navigator.pushNamed(context, '/car_details',arguments: car);
                        },
                        name: car.model,
                        price: car.price,
                        speed: car.topSpeed.toDouble(),
                        hp: car.horsepower,
                        image: car.interiorColor,
                      );
                    },
                  ),
                );
              }
              else {
                return SliverToBoxAdapter(child: SizedBox.shrink());
              }
            },
          ),
        ],
      ),
    );
  }
}
