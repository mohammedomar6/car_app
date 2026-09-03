import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/utils/whatsapp_launcher.dart';
import 'package:car_app/features/admin/presentation/manager/users/users_bloc.dart';
import 'package:car_app/features/orders/data/models/order_model.dart';
import 'package:car_app/features/profile/data/models/profile_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> showOrderPartiesSheet(
  BuildContext context,
  OrderModel order,
) {
  return _showPartiesSheet(
    context,
    title: 'ui_178'.tr(),
    subtitle: 'dyn_buyer_seller_order'.tr(
      namedArgs: {'id': '${order.orderId}'},
    ),
    buyerId: order.userId,
    sellerId: order.sellerId,
    carId: order.carId,
  );
}

Future<void> showTransactionPartiesSheet(
  BuildContext context, {
  required int transactionId,
  required int buyerId,
  required int sellerId,
  required int carId,
}) {
  return _showPartiesSheet(
    context,
    title: 'ui_269'.tr(),
    subtitle: 'dyn_buyer_seller_transaction'.tr(
      namedArgs: {'id': '$transactionId'},
    ),
    buyerId: buyerId,
    sellerId: sellerId,
    carId: carId,
  );
}

Future<void> _showPartiesSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required int buyerId,
  required int? sellerId,
  required int carId,
}) async {
  final usersBloc = context.read<UsersBloc>();
  if (usersBloc.state.status == UsersStatus.initial ||
      usersBloc.state.status == UsersStatus.failure) {
    usersBloc.add(GetAllUser());
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Color(0xFF171919),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
    builder: (sheetContext) => BlocBuilder<UsersBloc, UsersState>(
      bloc: usersBloc,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            18.w,
            12.h,
            18.w,
            24.h + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: _PartiesContent(
            title: title,
            subtitle: subtitle,
            buyerId: buyerId,
            sellerId: sellerId,
            carId: carId,
            state: state,
          ),
        );
      },
    ),
  );
}

class _PartiesContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final int buyerId;
  final int? sellerId;
  final int carId;
  final UsersState state;

  _PartiesContent({
    required this.title,
    required this.subtitle,
    required this.buyerId,
    required this.sellerId,
    required this.carId,
    required this.state,
  });

  ProfileResponseModel? _findUser(int? id) {
    if (id == null) return null;
    for (final user in state.users) {
      if (user.userId == id) return user;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (state.status == UsersStatus.loading && state.users.isEmpty) {
      return SizedBox(
        height: 300.h,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }
    if (state.status == UsersStatus.failure && state.users.isEmpty) {
      return SizedBox(
        height: 320.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: Color(0xFFFF6B76)),
            SizedBox(height: 12.h),
            Text(
              state.message.replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              onPressed: () => context.read<UsersBloc>().add(GetAllUser()),
              icon: Icon(Icons.refresh_rounded),
              label: Text('ui_275'.tr()),
            ),
          ],
        ),
      );
    }

    final buyer = _findUser(buyerId);
    final seller = _findUser(sellerId);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 46.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.people_alt_rounded,
                  color: AppColors.secondary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _PartyCard(
            title: 'ui_054'.tr(),
            subtitle: 'ui_244'.tr(),
            icon: Icons.shopping_bag_rounded,
            color: Color(0xFF58A6FF),
            userId: buyerId,
            user: buyer,
          ),
          SizedBox(height: 12.h),
          _PartyCard(
            title: 'ui_238'.tr(),
            subtitle: 'dyn_owner_car'.tr(namedArgs: {'id': '$carId'}),
            icon: Icons.storefront_rounded,
            color: Color(0xFF35C68B),
            userId: sellerId,
            user: seller,
          ),
        ],
      ),
    );
  }
}

class _PartyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int? userId;
  final ProfileResponseModel? user;

  _PartyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.userId,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 22.r),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.white54, fontSize: 9.sp),
                    ),
                  ],
                ),
              ),
              Text(
                userId == null ? 'ID —' : '#$userId',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (userId == null)
            _MissingProfile(
              message: 'ui_252'.tr(),
            )
          else if (user == null)
            _MissingProfile(
              message: 'ui_257'.tr(),
            )
          else ...[
            _ContactRow(
              icon: Icons.person_rounded,
              label: 'ui_150'.tr(),
              value: user!.fullName,
            ),
            _ContactRow(
              icon: Icons.email_rounded,
              label: 'ui_113'.tr(),
              value: user!.email,
            ),
            _ContactRow(
              icon: Icons.phone_rounded,
              label: 'ui_196'.tr(),
              value: user!.phone,
              isLast: true,
              actionIcon: Icons.chat_rounded,
              actionColor: const Color(0xFF25D366),
              onTap: () => openWhatsAppChat(context, user!.phone),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isLast;
  final IconData? actionIcon;
  final Color? actionColor;
  final VoidCallback? onTap;

  _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
    this.actionIcon,
    this.actionColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12.r),
    child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.r, color: Colors.white38),
            SizedBox(width: 9.w),
            SizedBox(
              width: 52.w,
              child: Text(
                label,
                style: TextStyle(color: Colors.white38, fontSize: 10.sp),
              ),
            ),
            Expanded(
              child: SelectableText(
                (value ?? '').trim().isEmpty ? '—' : value!,
                textAlign: TextAlign.end,
                style: TextStyle(color: Colors.white, fontSize: 11.sp),
              ),
            ),
            if (actionIcon != null) ...[
              SizedBox(width: 8.w),
              Icon(actionIcon, color: actionColor, size: 20.r),
            ],
          ],
        ),
      ),
  );
}

class _MissingProfile extends StatelessWidget {
  final String message;

  _MissingProfile({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 10.sp),
        ),
      );
}
