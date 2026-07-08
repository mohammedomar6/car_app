import 'package:car_app/features/auth/presentation/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';


class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                // ScaffoldMessenger.of(context).showSnackBar(
                // SnackBar(
                //   behavior: SnackBarBehavior.floating,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(15.r),
                //   ),
                //   showCloseIcon: true,
                //   backgroundColor: Color(0xff1C1C1C),
                //   content: Padding(
                //     padding: EdgeInsets.symmetric(vertical: 5.h),
                //     child: Row(
                //       children: [
                //         Container(
                //           height: 45.h,
                //           width: 45.w,
                //           decoration: BoxDecoration(
                //             shape: BoxShape.circle,
                //             color: Color(0x1aff6b00),
                //           ),
                //           child: Icon(
                //             Icons.directions_car,
                //             color: Color(0xffff6b00),
                //           ),
                //         ),
                //
                //         SizedBox(width: 10),
                //
                //         Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text("successfully",style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 15),),
                //             Text("Car added successfully"),
                //           ],
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                //);


                // if (success) {
                //
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: Text("تمت العملية بنجاح"),
                //
                //       action: SnackBarAction(
                //         label: "إغلاق",
                //
                //         onPressed: () {
                //           ScaffoldMessenger.of(context)
                //               .hideCurrentSnackBar();
                //         },
                //       ),
                //     ),
                //   );
                //
                // } else {
                //
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: Text("حدث خطأ"),
                //
                //       action: SnackBarAction(
                //         label: "إعادة",
                //
                //         onPressed: () {
                //
                //           emailController.clear();
                //           passwordController.clear();
                //
                //         },
                //       ),
                //     ),
                //   );
                //   }
                // },
              },
        child:Text("data")

              ),
          ),
        ],
      ),
    );
  }
}
