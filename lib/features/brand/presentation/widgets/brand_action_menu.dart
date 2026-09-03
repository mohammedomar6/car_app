import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BrandActionMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  BrandActionMenu({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.only(
            top: 12.h,
            bottom: 20.h,
            left: 20.w,
            right: 20.w,
          ),
          decoration: BoxDecoration(
            color: AppColors.darkGrey,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 45.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.textAuth,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),

              SizedBox(height: 20.h),

              Text('ui_050'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              ),

              SizedBox(height: 20.h),

              // EDIT
              ListTile(
                leading: Container(
                  width: 45.r,
                  height: 45.r,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppColors.secondary,
                  ),
                ),
                title:  Text('ui_108'.tr(),style: TextStyle(color: AppColors.textAuth),),
                subtitle:  Text('ui_068'.tr(),
                  style: TextStyle(color:AppColors.backgroundLight ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onEdit();
                },
              ),

              SizedBox(height: 5.h),

              // DELETE
              ListTile(
                leading: Container(
                  width: 45.r,
                  height: 45.r,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.secondary,
                  ),
                ),
                title:  Text('ui_096'.tr(),style: TextStyle(color: AppColors.textAuth),),
                subtitle:  Text('ui_216'.tr(),
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onDelete();
                },
              ),

              SizedBox(height: 10.h),

              // CANCEL
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                  },
                  child: Text('ui_055'.tr()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 5.h,
      right: 5.w,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () => _showActions(context),
          child: Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.65),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.more_horiz,
              color: Colors.white,
              size: 21.r,
            ),
          ),
        ),
      ),
    );
  }
}