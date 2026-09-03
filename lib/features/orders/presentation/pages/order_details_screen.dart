import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/localization/localized_value.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/orders/data/models/order_model.dart';
import 'package:car_app/features/orders/presentation/manager/order_bloc.dart';
import 'package:car_app/features/orders/presentation/utils/order_car_navigation.dart';
import 'package:car_app/features/orders/presentation/utils/order_details_arguments.dart';
import 'package:car_app/features/orders/presentation/widgets/order_document_viewer.dart';
import 'package:car_app/features/orders/presentation/widgets/order_widgets.dart';
import 'package:car_app/features/orders/presentation/widgets/order_parties_sheet.dart';
import 'package:car_app/features/transactions/presentation/utils/transaction_route_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  final bool isAdmin;
  final bool focusDocuments;

  OrderDetailsScreen({
    super.key,
    required this.orderId,
    this.isAdmin = false,
    this.focusDocuments = false,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final _documentsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(LoadOrderDetailsEvent(widget.orderId));
  }

  Future<void> _cancelOrder(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB547)),
        title: Text('ui_058'.tr()),
        content: Text('ui_251'.tr(),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('ui_127'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF5F6D),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('ui_056'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<OrderBloc>().add(CancelOrderEvent(order.orderId));
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

  Future<void> _openTransactionFlow(OrderModel order) async {
    if (order.orderStatus.toLowerCase() == 'completed') {
      await Navigator.pushNamed(
        context,
        AppRoutes.transactions,
        arguments: TransactionsScreenArguments(
          isAdmin: widget.isAdmin,
          initialOrderId: order.orderId,
        ),
      );
      return;
    }
    final bloc = context.read<OrderBloc>();
    final created = await Navigator.pushNamed<dynamic>(
      context,
      AppRoutes.transactionForm,
      arguments: TransactionFormArguments(order: order),
    );
    if (created == true && mounted) {
      bloc.add(LoadOrderDetailsEvent(order.orderId));
      bloc.add(
        LoadAdminOrdersEvent(
          status: bloc.state.adminStatusFilter,
          type: bloc.state.adminTypeFilter,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderBloc, OrderState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus ||
          previous.detailsStatus != current.detailsStatus,
      listener: (context, state) {
        if (widget.focusDocuments &&
            state.detailsStatus == OrderRequestStatus.success) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final documentContext = _documentsKey.currentContext;
            if (documentContext != null) {
              Scrollable.ensureVisible(
                documentContext,
                duration: Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
              );
            }
          });
        }
        if (state.actionStatus == OrderRequestStatus.success) {
          _showSnack(state.message);
          context.read<OrderBloc>().add(ResetOrderFeedbackEvent());
        } else if (state.actionStatus == OrderRequestStatus.failure) {
          _showSnack(state.errorMessage, isError: true);
          context.read<OrderBloc>().add(ResetOrderFeedbackEvent());
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'dyn_order_number'.tr(namedArgs: {'id': '${widget.orderId}'}),
            ),
            actions: [
              IconButton(
                onPressed: () => context
                    .read<OrderBloc>()
                    .add(LoadOrderDetailsEvent(widget.orderId)),
                icon: Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(OrderState state) {
    if (state.detailsStatus == OrderRequestStatus.loading) {
      return Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }
    if (state.detailsStatus == OrderRequestStatus.failure) {
      return OrdersEmptyState(
        title: 'ui_082'.tr(),
        subtitle: state.errorMessage,
        onRefresh: () => context
            .read<OrderBloc>()
            .add(LoadOrderDetailsEvent(widget.orderId)),
      );
    }

    final order = state.selectedOrder;
    if (order == null || order.orderId != widget.orderId) {
      return OrdersEmptyState(
        title: 'ui_176'.tr(),
        subtitle: 'ui_255'.tr(),
      );
    }
    final isPending = order.orderStatus.toLowerCase() == 'pending';
    final canCreateContract = widget.isAdmin &&
        order.orderStatus.toLowerCase() == 'approved';
    final canViewContract = order.orderStatus.toLowerCase() == 'completed';
    final isCanceling = state.actionStatus == OrderRequestStatus.loading &&
        state.processingOrderId == order.orderId;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 30.h),
      child: Column(
        children: [
          _OrderDetailsHero(order: order),
          SizedBox(height: 16.h),
          _OrderProgress(order: order),
          SizedBox(height: 16.h),
          OrderSectionCard(
            title: 'ui_174'.tr(),
            icon: Icons.receipt_long_rounded,
            child: Column(
              children: [
                OrderInfoRow(label: 'ui_177'.tr(), value: '#${order.orderId}'),
                if (widget.isAdmin)
                  OrderInfoRow(label: 'ui_054'.tr(), value: 'User #${order.userId}'),
                if (widget.isAdmin)
                  OrderInfoRow(
                    label: 'ui_238'.tr(),
                    value: order.sellerId == null
                        ? 'extra_065'.tr()
                        : 'User #${order.sellerId}',
                  ),
                OrderInfoRow(label: 'ui_059'.tr(), value: 'Car #${order.carId}'),
                OrderInfoRow(
                  label: 'ui_221'.tr(),
                  value: order.orderType.localized,
                ),
                OrderInfoRow(
                  label: 'ui_090'.tr(),
                  value: formatOrderDateTime(order.createdAt),
                ),
                OrderInfoRow(
                  label: 'ui_263'.tr(),
                  value: '\$${order.totalPrice.toStringAsFixed(2)}',
                  isLast: true,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: OutlinedButton.icon(
              onPressed: () => OrderCarNavigation.openCarDetails(
                context,
                order.carId,
              ),
              icon: Icon(Icons.directions_car_rounded),
              label: Text('ui_298'.tr()),
            ),
          ),
          if (widget.isAdmin) ...[
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: OutlinedButton.icon(
                onPressed: () => showOrderPartiesSheet(context, order),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFF58A6FF),
                  side: BorderSide(color: Color(0x5558A6FF)),
                ),
                icon: Icon(Icons.people_alt_rounded),
                label: Text('ui_296'.tr()),
              ),
            ),
          ],
          if (canCreateContract || canViewContract) ...[
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: () => _openTransactionFlow(order),
                icon: Icon(
                  canViewContract
                      ? Icons.description_rounded
                      : Icons.handshake_rounded,
                ),
                label: Text(
                  canViewContract
                      ? 'extra_107'.tr()
                      : 'Create contract and complete order',
                ),
              ),
            ),
          ],
          if (order.rentDetails != null) ...[
            SizedBox(height: 16.h),
            OrderSectionCard(
              title: 'ui_218'.tr(),
              icon: Icons.calendar_month_rounded,
              child: Column(
                children: [
                  OrderInfoRow(
                    label: 'ui_199'.tr(),
                    value: formatOrderDate(order.rentDetails!.startDate),
                  ),
                  OrderInfoRow(
                    label: 'ui_226'.tr(),
                    value: formatOrderDate(order.rentDetails!.endDate),
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
          if (order.installmentDetails != null) ...[
            SizedBox(height: 16.h),
            OrderSectionCard(
              title: 'ui_131'.tr(),
              icon: Icons.account_balance_wallet_rounded,
              child: Column(
                children: [
                  OrderInfoRow(
                    label: 'ui_193'.tr(),
                    value: '${order.installmentDetails!.installmentMonths} months',
                  ),
                  if (order.installmentDetails!.monthlyPayment != null)
                    OrderInfoRow(
                      label: 'ui_147'.tr(),
                      value:
                          '\$${order.installmentDetails!.monthlyPayment!.toStringAsFixed(2)}',
                    ),
                  if (order.installmentDetails!.downPayment != null)
                    OrderInfoRow(
                      label: 'ui_105'.tr(),
                      value:
                          '\$${order.installmentDetails!.downPayment!.toStringAsFixed(2)}',
                      isLast: true,
                    ),
                ],
              ),
            ),
          ],
          SizedBox(height: 16.h),
          OrderSectionCard(
            title: 'ui_167'.tr(),
            icon: Icons.chat_bubble_outline_rounded,
            child: Column(
              children: [
                _NoteBox(
                  label: 'ui_314'.tr(),
                  value: order.userNotes,
                ),
                if ((order.adminNotes ?? '').trim().isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  _NoteBox(
                    label: 'ui_014'.tr(),
                    value: order.adminNotes!,
                    highlighted: true,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
          OrderSectionCard(
            key: _documentsKey,
            title: 'ui_103'.tr(),
            icon: Icons.folder_copy_rounded,
            child: order.documentUrls.isEmpty
                ? Text('ui_161'.tr(),
                    style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                  )
                : OrderDocumentViewer(
                    documentUrls: order.documentUrls,
                  ),
          ),
          if (!widget.isAdmin && isPending) ...[
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: OutlinedButton.icon(
                onPressed: isCanceling ? null : () => _cancelOrder(order),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFFFF6B76),
                  side: BorderSide(color: Color(0x55FF6B76)),
                ),
                icon: isCanceling
                    ? SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.close_rounded),
                label: Text('ui_057'.tr()),
              ),
            ),
          ],
        ],
      ),
    );
  }

}

class _OrderDetailsHero extends StatelessWidget {
  final OrderModel order;

  _OrderDetailsHero({required this.order});

  @override
  Widget build(BuildContext context) {
    final color = orderStatusColor(order.orderStatus);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.25), Color(0xFF151717)],
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
                width: 58.r,
                height: 58.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(17.r),
                ),
                child: Icon(orderTypeIcon(order.orderType), color: color, size: 29.r),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'dyn_request_type'.tr(
                        namedArgs: {'type': order.orderType.localized},
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'dyn_submitted'.tr(namedArgs: {
                        'date': formatOrderDate(order.createdAt),
                      }),
                      style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
              OrderStatusBadge(status: order.orderStatus),
            ],
          ),
          SizedBox(height: 18.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 13.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              children: [
                Text('ui_247'.tr(),
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 9.sp,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '\$${order.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.secondary,
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

class _OrderProgress extends StatelessWidget {
  final OrderModel order;

  _OrderProgress({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.orderStatus.toLowerCase();
    final terminal = status == 'rejected' || status == 'canceled' || status == 'cancelled';
    final approved = status == 'approved' || status == 'completed';
    final completed = status == 'completed';
    return OrderSectionCard(
      title: 'ui_220'.tr(),
      icon: Icons.route_rounded,
      child: Row(
        children: [
          _ProgressStep(label: 'ui_239'.tr(), active: true),
          _ProgressLine(active: approved || completed || terminal),
          _ProgressStep(
            label: terminal ? order.orderStatus : 'Approved',
            active: approved || completed || terminal,
            danger: terminal,
          ),
          _ProgressLine(active: completed),
          _ProgressStep(label: 'ui_074'.tr(), active: completed),
        ],
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String label;
  final bool active;
  final bool danger;

  _ProgressStep({
    required this.label,
    required this.active,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? Color(0xFFFF5F6D)
        : (active ? AppColors.secondary : Colors.white24);
    return SizedBox(
      width: 70.w,
      child: Column(
        children: [
          Container(
            width: 27.r,
            height: 27.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: active ? 0.18 : 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Icon(
              danger ? Icons.close_rounded : Icons.check_rounded,
              color: color,
              size: 15.r,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 8.sp),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final bool active;

  _ProgressLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 20.h),
        color: active ? AppColors.secondary : Colors.white12,
      ),
    );
  }
}

class _NoteBox extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;

  _NoteBox({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(13.r),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.secondary.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlighted ? AppColors.secondary : Colors.white38,
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value.trim().isEmpty ? 'extra_061'.tr() : value,
            style: TextStyle(color: Colors.white70, fontSize: 11.sp, height: 1.5),
          ),
        ],
      ),
    );
  }
}
