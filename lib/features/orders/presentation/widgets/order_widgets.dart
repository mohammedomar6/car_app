import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/localization/localized_value.dart';
import 'package:car_app/features/orders/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Color orderStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return Color(0xFF35C68B);
    case 'rejected':
      return Color(0xFFFF5F6D);
    case 'completed':
      return Color(0xFF58A6FF);
    case 'canceled':
    case 'cancelled':
      return Color(0xFF90949B);
    default:
      return Color(0xFFFFB547);
  }
}

IconData orderTypeIcon(String type) {
  switch (type.toLowerCase()) {
    case 'rent':
      return Icons.calendar_month_rounded;
    case 'installment':
      return Icons.account_balance_wallet_rounded;
    default:
      return Icons.shopping_bag_rounded;
  }
}

String formatOrderDate(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/${local.year}';
}

String formatOrderDateTime(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '${formatOrderDate(local)}  '
      '${hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')} $period';
}

class OrderStatusBadge extends StatelessWidget {
  final String status;

  OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = orderStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.r,
            height: 7.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 7.w),
          Text(
            (status.isEmpty ? 'Pending' : status).localized,
            style: TextStyle(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isAdmin;
  final bool isProcessing;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onViewCar;
  final VoidCallback? onViewDocuments;
  final VoidCallback? onViewParties;
  final VoidCallback? onTransaction;
  final String transactionLabel;

  OrderCard({
    super.key,
    required this.order,
    this.isAdmin = false,
    this.isProcessing = false,
    this.onTap,
    this.onCancel,
    this.onApprove,
    this.onReject,
    this.onViewCar,
    this.onViewDocuments,
    this.onViewParties,
    this.onTransaction,
    this.transactionLabel = '',
  });

  bool get _isPending => order.orderStatus.toLowerCase() == 'pending';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.075),
            Colors.white.withValues(alpha: 0.025),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50.r,
                      height: 50.r,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Icon(
                        orderTypeIcon(order.orderType),
                        color: AppColors.secondary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'dyn_order_type'.tr(
                              namedArgs: {'type': order.orderType.localized},
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            (isAdmin ? 'dyn_order_buyer' : 'dyn_order_car')
                                .tr(namedArgs: {
                              'order': '${order.orderId}',
                              'target': '${isAdmin ? order.userId : order.carId}',
                            }),
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OrderStatusBadge(status: order.orderStatus),
                  ],
                ),
                SizedBox(height: 15.h),
                Container(
                  padding: EdgeInsets.all(13.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MiniInfo(
                          label: 'ui_262'.tr(),
                          value: '\$${order.totalPrice.toStringAsFixed(2)}',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 32.h,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      Expanded(
                        child: _MiniInfo(
                          label: 'ui_089'.tr(),
                          value: formatOrderDate(order.createdAt),
                        ),
                      ),
                      if (isAdmin) ...[
                        Container(
                          width: 1,
                          height: 32.h,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        Expanded(
                          child: _MiniInfo(
                            label: 'ui_059'.tr(),
                            value: '#${order.carId}',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onViewCar != null ||
                    (isAdmin && onViewParties != null) ||
                    (isAdmin &&
                        order.documentUrls.isNotEmpty &&
                        onViewDocuments != null)) ...[
                  SizedBox(height: 11.h),
                  Row(
                    children: [
                      if (onViewCar != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onViewCar,
                            icon: Icon(
                              Icons.directions_car_rounded,
                              size: 18,
                            ),
                            label: Text('ui_297'.tr()),
                          ),
                        ),
                      if (isAdmin && onViewParties != null) ...[
                        if (onViewCar != null) SizedBox(width: 9.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onViewParties,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF58A6FF),
                              side: BorderSide(color: Color(0x5558A6FF)),
                            ),
                            icon: Icon(Icons.people_alt_rounded, size: 18),
                            label: Text('ui_185'.tr()),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isAdmin &&
                      order.documentUrls.isNotEmpty &&
                      onViewDocuments != null) ...[
                    SizedBox(height: 9.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onViewDocuments,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                          side: BorderSide(
                            color: AppColors.secondary.withValues(alpha: 0.35),
                          ),
                        ),
                        icon: Icon(Icons.folder_open_rounded, size: 18),
                        label: Text(
                          'dyn_documents_count'.tr(
                            namedArgs: {
                              'count': '${order.documentUrls.length}',
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
                if (onTransaction != null) ...[
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onTransaction,
                      icon: Icon(Icons.handshake_rounded),
                      label: Text(
                        transactionLabel.isEmpty
                            ? 'extra_032'.tr()
                            : transactionLabel,
                      ),
                    ),
                  ),
                ],
                if (_isPending &&
                    (onCancel != null || onApprove != null || onReject != null)) ...[
                  SizedBox(height: 13.h),
                  if (isProcessing)
                    SizedBox(
                      height: 42.h,
                      child: Center(
                        child: SizedBox(
                          width: 22.r,
                          height: 22.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        if (onCancel != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onCancel,
                              icon: Icon(Icons.close_rounded, size: 18),
                              label: Text('ui_056'.tr()),
                            ),
                          ),
                        if (onReject != null) ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onReject,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Color(0xFFFF6B76),
                                side: BorderSide(color: Color(0x55FF6B76)),
                              ),
                              icon: Icon(Icons.close_rounded, size: 18),
                              label: Text('ui_213'.tr()),
                            ),
                          ),
                          SizedBox(width: 10.w),
                        ],
                        if (onApprove != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: onApprove,
                              icon: Icon(Icons.check_rounded, size: 18),
                              label: Text('ui_032'.tr()),
                            ),
                          ),
                      ],
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;

  _MiniInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white38, fontSize: 10.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}

class OrderSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  OrderSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(17.r),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(21.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.075)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 35.r,
                height: 35.r,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColors.secondary, size: 19.r),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

class OrderInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  OrderInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h, top: 2.h),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.white54, fontSize: 12.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Flexible(
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrdersEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRefresh;

  OrdersEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86.r,
              height: 86.r,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 38.r,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12.sp),
            ),
            if (onRefresh != null) ...[
              SizedBox(height: 20.h),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: Icon(Icons.refresh_rounded),
                label: Text('ui_275'.tr()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
