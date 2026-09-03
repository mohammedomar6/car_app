import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/localization/localized_value.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/orders/presentation/utils/order_details_arguments.dart';
import 'package:car_app/features/orders/presentation/utils/order_car_navigation.dart';
import 'package:car_app/features/orders/presentation/widgets/order_parties_sheet.dart';
import 'package:car_app/features/transactions/data/models/transaction_model.dart';
import 'package:car_app/features/transactions/presentation/manager/transaction_bloc.dart';
import 'package:car_app/features/transactions/presentation/utils/transaction_route_arguments.dart';
import 'package:car_app/features/transactions/presentation/widgets/contract_image_gallery.dart';
import 'package:car_app/features/transactions/presentation/widgets/transaction_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final int transactionId;
  final bool isAdmin;

  TransactionDetailsScreen({
    super.key,
    required this.transactionId,
    this.isAdmin = false,
  });

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<TransactionBloc>().add(
          LoadTransactionDetailsEvent(widget.transactionId),
        );
  }

  Future<void> _edit(TransactionModel transaction) async {
    final changed = await Navigator.pushNamed<dynamic>(
      context,
      AppRoutes.transactionForm,
      arguments: TransactionFormArguments(
        transaction: transaction,
      ),
    );
    if (changed == true && mounted) _load();
  }

  Future<void> _delete(TransactionModel transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B76)),
        title: Text('ui_097'.tr()),
        content: Text('ui_256'.tr(),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('ui_055'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF5F6D),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('ui_094'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<TransactionBloc>().add(
            DeleteTransactionEvent(transaction.transactionId),
          );
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError ? Color(0xFF8B3038) : Color(0xFF176B50),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == TransactionRequestStatus.success) {
          _showSnack(state.message);
          context.read<TransactionBloc>().add(
                ResetTransactionFeedbackEvent(),
              );
          Navigator.pop(context, true);
        } else if (state.actionStatus == TransactionRequestStatus.failure) {
          _showSnack(state.errorMessage, isError: true);
          context.read<TransactionBloc>().add(
                ResetTransactionFeedbackEvent(),
              );
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(
            'dyn_transaction_number'.tr(
              namedArgs: {'id': '${widget.transactionId}'},
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'ui_210'.tr(),
              onPressed: _load,
              icon: Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(TransactionState state) {
    if (state.detailsStatus == TransactionRequestStatus.loading) {
      return Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }
    if (state.detailsStatus == TransactionRequestStatus.failure) {
      return TransactionsEmptyState(
        title: 'ui_083'.tr(),
        subtitle: state.errorMessage,
        onRefresh: _load,
      );
    }
    final transaction = state.selectedTransaction;
    if (transaction == null ||
        transaction.transactionId != widget.transactionId) {
      return TransactionsEmptyState(
        title: 'ui_268'.tr(),
        subtitle: 'ui_254'.tr(),
      );
    }

    final deleting = state.actionStatus == TransactionRequestStatus.loading &&
        state.processingTransactionId == transaction.transactionId;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 30.h),
      child: Column(
        children: [
          _TransactionHero(transaction: transaction),
          SizedBox(height: 14.h),
          TransactionSectionCard(
            title: 'ui_267'.tr(),
            icon: Icons.receipt_long_rounded,
            child: Column(
              children: [
                TransactionInfoRow(
                  label: 'ui_266'.tr(),
                  value: '#${transaction.transactionId}',
                ),
                TransactionInfoRow(
                  label: 'ui_171'.tr(),
                  value: '#${transaction.orderId}',
                ),
                TransactionInfoRow(
                  label: 'ui_059'.tr(),
                  value: '#${transaction.carId}',
                ),
                TransactionInfoRow(
                  label: 'ui_054'.tr(),
                  value: 'User #${transaction.buyerId}',
                ),
                TransactionInfoRow(
                  label: 'ui_238'.tr(),
                  value: 'User #${transaction.sellerId}',
                ),
                TransactionInfoRow(
                  label: 'ui_180'.tr(),
                  value: transaction.orderStatus,
                ),
                TransactionInfoRow(
                  label: 'ui_090'.tr(),
                  value: formatTransactionDate(
                    transaction.createdAt,
                    includeTime: true,
                  ),
                  isLast: transaction.updatedAt == null,
                ),
                if (transaction.updatedAt != null)
                  TransactionInfoRow(
                    label: 'ui_137'.tr(),
                    value: formatTransactionDate(
                      transaction.updatedAt,
                      includeTime: true,
                    ),
                    isLast: true,
                  ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => OrderCarNavigation.openCarDetails(
                    context,
                    transaction.carId,
                  ),
                  icon: Icon(Icons.directions_car_rounded),
                  label: Text('ui_297'.tr()),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.orderDetails,
                    arguments: OrderDetailsArguments(
                      orderId: transaction.orderId,
                      isAdmin: widget.isAdmin,
                    ),
                  ),
                  icon: Icon(Icons.receipt_rounded),
                  label: Text('ui_302'.tr()),
                ),
              ),
            ],
          ),
          if (widget.isAdmin) ...[
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: OutlinedButton.icon(
                onPressed: () => showTransactionPartiesSheet(
                  context,
                  transactionId: transaction.transactionId,
                  buyerId: transaction.buyerId,
                  sellerId: transaction.sellerId,
                  carId: transaction.carId,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFF58A6FF),
                  side: BorderSide(color: Color(0x5558A6FF)),
                ),
                icon: Icon(Icons.people_alt_rounded),
                label: Text('ui_296'.tr()),
              ),
            ),
          ],
          SizedBox(height: 14.h),
          TransactionSectionCard(
            title: 'ui_188'.tr(),
            icon: Icons.payments_rounded,
            child: Column(
              children: [
                TransactionInfoRow(
                  label: 'ui_022'.tr(),
                  value: '\$${transaction.amount.toStringAsFixed(2)}',
                ),
                TransactionInfoRow(
                  label: 'ui_191'.tr(),
                  value: transaction.paymentMethod,
                ),
                TransactionInfoRow(
                  label: 'ui_273'.tr(),
                  value: _typeLabel(transaction.transactionType),
                ),
                TransactionInfoRow(
                  label: 'ui_209'.tr(),
                  value: transaction.referenceNumber,
                  isLast: true,
                ),
              ],
            ),
          ),
          if (transaction.notes.trim().isNotEmpty) ...[
            SizedBox(height: 14.h),
            TransactionSectionCard(
              title: 'ui_167'.tr(),
              icon: Icons.notes_rounded,
              child: SelectableText(
                transaction.notes,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.sp,
                  height: 1.55,
                ),
              ),
            ),
          ],
          SizedBox(height: 14.h),
          TransactionSectionCard(
            title: 'ui_241'.tr(),
            icon: Icons.photo_library_rounded,
            child: ContractImageGallery(images: transaction.contractImages),
          ),
          if (widget.isAdmin) ...[
            SizedBox(height: 18.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: deleting ? null : () => _delete(transaction),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFFFF6B76),
                      side: BorderSide(color: Color(0x55FF6B76)),
                    ),
                    icon: Icon(Icons.delete_outline_rounded),
                    label: Text('ui_098'.tr()),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: deleting ? null : () => _edit(transaction),
                    icon: Icon(Icons.edit_rounded),
                    label: Text('ui_111'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionHero extends StatelessWidget {
  final TransactionModel transaction;

  _TransactionHero({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = transactionStatusColor(transaction.status);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.26), Color(0xFF151717)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  transactionTypeIcon(transaction.transactionType),
                  color: color,
                  size: 28.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _typeLabel(transaction.transactionType),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      transaction.paymentMethod,
                      style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
              TransactionStatusBadge(status: transaction.status),
            ],
          ),
          SizedBox(height: 17.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 13.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              children: [
                Text('ui_248'.tr(),
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 8.sp,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _typeLabel(String value) {
  return (value.isEmpty ? 'Transaction' : value).localized;
}
