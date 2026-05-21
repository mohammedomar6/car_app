import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_image.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(fit: StackFit.expand,
        children: [
          Image.asset(AppImage.backgroundAuth,fit: BoxFit.cover,),

        ],
      ),
    );
  }
}
