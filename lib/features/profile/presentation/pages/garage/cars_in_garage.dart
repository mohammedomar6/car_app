import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/home/presentation/widgets/card_car.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarsInGarage extends StatelessWidget {
  const CarsInGarage({super.key});

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
          SliverToBoxAdapter(
            child: SizedBox(
              height: 700.h,
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return CardCar(
                    name: "name",
                    price: 19,
                    speed: 100,
                    hp: 6889,
                    image: "assets/image/home/redCar.png",
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
