import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/localization/localized_value.dart';
import 'package:car_app/features/transactions/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Color transactionStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return Color(0xFF35C68B);
    case 'refunded':
      return Color(0xFF58A6FF);
    case 'failed':
      return Color(0xFFFF5F6D);
    default:
      return Color(0xFFFFB547);
  }
}

IconData transactionTypeIcon(String type) {
  switch (type.toLowerCase()) {
    case 'deposit':
      return Icons.savings_rounded;
    case 'installmentpayment':
      return Icons.calendar_view_month_rounded;
    default:
      return Icons.account_balance_wallet_rounded;
  }
}

String formatTransactionDate(DateTime? date, {bool includeTime = false}) {
  if (date == null) return '—';
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final base = '$day/$month/${local.year}';
  if (!includeTime) return base;
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$base  $hour:$minute';
}

class TransactionStatusBadge extends StatelessWidget {
  final String status;

  TransactionStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final effective = status.isEmpty ? 'Pending' : status;
    final color = transactionStatusColor(effective);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.r,
            height: 7.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            effective.localized,
            style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final bool isAdmin;
  final bool isProcessing;
  final VoidCallback onTap;
  final VoidCallback? onViewCar;
  final VoidCallback? onViewOrder;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  TransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
    this.isAdmin = false,
    this.isProcessing = false,
    this.onViewCar,
    this.onViewOrder,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = transactionStatusColor(transaction.status);
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.09),
            Colors.white.withValues(alpha: 0.025),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: color.withValues(alpha: 0.19)),
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
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Icon(
                        transactionTypeIcon(transaction.transactionType),
                        color: color,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _transactionTypeLabel(transaction.transactionType),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'dyn_transaction_order'.tr(
                              namedArgs: {
                                'transaction': '${transaction.transactionId}',
                                'order': '${transaction.orderId}',
                              },
                            ),
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TransactionStatusBadge(status: transaction.status),
                  ],
                ),
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TransactionMiniInfo(
                          label: 'ui_022'.tr(),
                          value: '\$${transaction.amount.toStringAsFixed(2)}',
                        ),
                      ),
                      _MiniDivider(),
                      Expanded(
                        child: _TransactionMiniInfo(
                          label: 'ui_187'.tr(),
                          value: transaction.paymentMethod,
                        ),
                      ),
                      _MiniDivider(),
                      Expanded(
                        child: _TransactionMiniInfo(
                          label: 'ui_089'.tr(),
                          value: formatTransactionDate(transaction.createdAt),
                        ),
                      ),
                    ],
                  ),
                ),
                if (transaction.referenceNumber.trim().isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Icon(
                        Icons.tag_rounded,
                        color: Colors.white38,
                        size: 17,
                      ),
                      SizedBox(width: 7.w),
                      Text('ui_208'.tr(),
                        style: TextStyle(color: Colors.white38, fontSize: 9.sp),
                      ),
                      Spacer(),
                      Text(
                        transaction.referenceNumber,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                if (onViewCar != null || onViewOrder != null) ...[
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      if (onViewCar != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onViewCar,
                            icon: Icon(Icons.directions_car_rounded),
                            label: Text('ui_059'.tr()),
                          ),
                        ),
                      if (onViewOrder != null) ...[
                        if (onViewCar != null) SizedBox(width: 9.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onViewOrder,
                            icon: Icon(Icons.receipt_long_rounded),
                            label: Text('ui_171'.tr()),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (isAdmin && (onEdit != null || onDelete != null)) ...[
                  SizedBox(height: 11.h),
                  if (isProcessing)
                    SizedBox(
                      height: 42.h,
                      child: Center(
                        child: SizedBox(
                          width: 22.r,
                          height: 22.r,
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        if (onDelete != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onDelete,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Color(0xFFFF6B76),
                                side: BorderSide(
                                  color: Color(0x55FF6B76),
                                ),
                              ),
                              icon: Icon(Icons.delete_outline_rounded),
                              label: Text('ui_094'.tr()),
                            ),
                          ),
                        if (onEdit != null) ...[
                          if (onDelete != null) SizedBox(width: 9.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: onEdit,
                              icon: Icon(Icons.edit_rounded),
                              label: Text('ui_107'.tr()),
                            ),
                          ),
                        ],
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

class TransactionSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  TransactionSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
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
            SizedBox(height: 15.h),
            child,
          ],
        ),
      );
}

class TransactionInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  TransactionInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 11.h),
        margin: EdgeInsets.only(bottom: isLast ? 0 : 11.h),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: Colors.white54, fontSize: 11.sp),
              ),
            ),
            SizedBox(width: 12.w),
            Flexible(
              child: SelectableText(
                value.trim().isEmpty ? '—' : value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
}

class TransactionsEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRefresh;

  TransactionsEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: EdgeInsets.all(30.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84.r,
                height: 84.r,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: AppColors.secondary,
                  size: 38.r,
                ),
              ),
              SizedBox(height: 17.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 7.h),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 11.sp),
              ),
              if (onRefresh != null) ...[
                SizedBox(height: 18.h),
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

class _TransactionMiniInfo extends StatelessWidget {
  final String label;
  final String value;

  _TransactionMiniInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label, style: TextStyle(color: Colors.white38, fontSize: 8.sp)),
          SizedBox(height: 4.h),
          Text(
            value.trim().isEmpty ? '—' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}

class _MiniDivider extends StatelessWidget {
  _MiniDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 30.h,
        color: Colors.white.withValues(alpha: 0.08),
      );
}

String _transactionTypeLabel(String type) {
  return (type.isEmpty ? 'Transaction' : type).localized;
}
