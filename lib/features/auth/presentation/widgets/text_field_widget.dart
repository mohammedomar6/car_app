import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_icon.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return    Container(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 260,top: 10,bottom: 15),
            child: Text('Email Address',style:TextStyle(
              color: AppColors.text,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),),
          ),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration:InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.darkgrey,
                  width: 2,
                ),
              ),
              focusColor: AppColors.grey,
              hintText: 'example@velocity.com',
              hintStyle: TextStyle(
                  color: AppColors.grey
              ),
              // filled: true,
              // fillColor: Colors.grey.shade200,
              prefixIcon: Icon(AppIcon.email,color: AppColors.text,),
              enabledBorder: OutlineInputBorder(

                  borderSide:  BorderSide(
                      color: AppColors.darkgrey
                  )
              ),



            ) ,
          ),
        ],
      ),
    );
  }
}
