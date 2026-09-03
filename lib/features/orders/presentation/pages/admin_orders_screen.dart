import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/localization/localized_value.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/orders/data/models/order_model.dart';
import 'package:car_app/features/orders/data/models/order_requests.dart';
import 'package:car_app/features/orders/presentation/manager/order_bloc.dart';
import 'package:car_app/features/orders/presentation/utils/order_details_arguments.dart';
import 'package:car_app/features/orders/presentation/utils/order_car_navigation.dart';
import 'package:car_app/features/orders/presentation/widgets/order_widgets.dart';
import 'package:car_app/features/orders/presentation/widgets/order_parties_sheet.dart';
import 'package:car_app/features/admin/presentation/manager/users/users_bloc.dart';
import 'package:car_app/features/transactions/presentation/utils/transaction_route_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminOrdersScreen extends StatefulWidget {
  AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  static const _statuses = [
    'Pending',
    'Approved',
    'Rejected',
    'Completed',
    'Canceled',
  ];
  static const _types = ['Buy', 'Rent', 'Installment'];

  String? _status = 'Pending';
  String? _type;

  @override
  void initState() {
    super.initState();
    _load();
    context.read<UsersBloc>().add(GetAllUser());
  }

  void _load() {
    context.read<OrderBloc>().add(
          LoadAdminOrdersEvent(status: _status, type: _type),
        );
  }

  Future<void> _refresh() async {
    final bloc = context.read<OrderBloc>();
    _load();
    await bloc.stream.firstWhere(
      (state) => state.adminOrdersStatus != OrderRequestStatus.loading,
    );
  }

  Future<void> _review(OrderModel order, String status) async {
    final notesController = TextEditingController();
    String? error;
    final notes = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          icon: Container(
            width: 58.r,
            height: 58.r,
            decoration: BoxDecoration(
              color: orderStatusColor(status).withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(
              status == 'Approved' ? Icons.check_rounded : Icons.close_rounded,
              color: orderStatusColor(status),
              size: 31.r,
            ),
          ),
          title: Text(
            'dyn_review_order'.tr(
              namedArgs: {
                'status': status.localized,
                'id': '${order.orderId}',
              },
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                status == 'Rejected'
                    ? 'extra_101'.tr()
                    : 'extra_108'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
              SizedBox(height: 14.h),
              TextField(
                controller: notesController,
                maxLines: 4,
                autofocus: status == 'Rejected',
                decoration: InputDecoration(
                  hintText: 'ui_015'.tr(),
                  errorText: error,
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.22),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.r),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('ui_055'.tr()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: orderStatusColor(status),
              ),
              onPressed: () {
                final value = notesController.text.trim();
                if (status == 'Rejected' && value.isEmpty) {
                  setDialogState(() => error = 'extra_002'.tr());
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  value.isEmpty ? 'extra_008'.tr() : value,
                );
              },
              child: Text(status.localized),
            ),
          ],
        ),
      ),
    );
    if (notes == null || !mounted) return;
    context.read<OrderBloc>().add(
          ReviewOrderEvent(
            ReviewOrderRequest(
              orderId: order.orderId,
              status: status,
              adminNotes: notes,
            ),
          ),
        );
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
          isAdmin: true,
          initialOrderId: order.orderId,
        ),
      );
      return;
    }
    final created = await Navigator.pushNamed<dynamic>(
      context,
      AppRoutes.transactionForm,
      arguments: TransactionFormArguments(order: order),
    );
    if (created == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderBloc, OrderState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == OrderRequestStatus.success) {
          _showSnack(state.message);
          context.read<OrderBloc>().add(ResetOrderFeedbackEvent());
          _load();
        } else if (state.actionStatus == OrderRequestStatus.failure) {
          _showSnack(state.errorMessage, isError: true);
          context.read<OrderBloc>().add(ResetOrderFeedbackEvent());
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('ui_175'.tr()),
            actions: [
              IconButton(
                onPressed: state.adminOrdersStatus == OrderRequestStatus.loading
                    ? null
                    : _load,
                icon: Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: Column(
            children: [
              _AdminOrdersHeader(orders: state.adminOrders),
              _buildFilters(),
              Expanded(child: _buildBody(state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: _FilterDropdown(
              label: 'ui_243'.tr(),
              value: _status,
              allLabel: 'ui_020'.tr(),
              values: _statuses,
              icon: Icons.filter_alt_rounded,
              onChanged: (value) {
                setState(() => _status = value);
                _load();
              },
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _FilterDropdown(
              label: 'ui_280'.tr(),
              value: _type,
              allLabel: 'ui_021'.tr(),
              values: _types,
              icon: Icons.category_rounded,
              onChanged: (value) {
                setState(() => _type = value);
                _load();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(OrderState state) {
    if (state.adminOrdersStatus == OrderRequestStatus.loading &&
        state.adminOrders.isEmpty) {
      return Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }
    if (state.adminOrdersStatus == OrderRequestStatus.failure &&
        state.adminOrders.isEmpty) {
      return OrdersEmptyState(
        title: 'ui_080'.tr(),
        subtitle: state.errorMessage,
        onRefresh: _load,
      );
    }
    if (state.adminOrders.isEmpty) {
      return OrdersEmptyState(
        title: 'ui_164'.tr(),
        subtitle: 'ui_278'.tr(),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.secondary,
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 25.h),
        itemCount: state.adminOrders.length,
        itemBuilder: (context, index) {
          final order = state.adminOrders[index];
          final isPending = order.orderStatus.toLowerCase() == 'pending';
          void openOrderDetails({bool focusDocuments = false}) {
            Navigator.pushNamed(
              context,
              AppRoutes.orderDetails,
              arguments: OrderDetailsArguments(
                orderId: order.orderId,
                isAdmin: true,
                focusDocuments: focusDocuments,
              ),
            );
          }

          return OrderCard(
            order: order,
            isAdmin: true,
            isProcessing: state.actionStatus == OrderRequestStatus.loading &&
                state.processingOrderId == order.orderId,
            onTap: () => openOrderDetails(),
            onViewCar: () => OrderCarNavigation.openCarDetails(
              context,
              order.carId,
            ),
            onViewDocuments: () => openOrderDetails(focusDocuments: true),
            onViewParties: () => showOrderPartiesSheet(context, order),
            onTransaction: {'approved', 'completed'}
                    .contains(order.orderStatus.toLowerCase())
                ? () => _openTransactionFlow(order)
                : null,
            transactionLabel: order.orderStatus.toLowerCase() == 'completed'
                ? 'extra_106'.tr()
                : 'Create contract',
            onApprove: isPending ? () => _review(order, 'Approved') : null,
            onReject: isPending ? () => _review(order, 'Rejected') : null,
          );
        },
      ),
    );
  }
}

class _AdminOrdersHeader extends StatelessWidget {
  final List<OrderModel> orders;

  _AdminOrdersHeader({required this.orders});

  @override
  Widget build(BuildContext context) {
    final totalValue = orders.fold<double>(
      0,
      (sum, order) => sum + order.totalPrice,
    );
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.24),
            Color(0xFF141616),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.secondary,
              size: 27.r,
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ui_227'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'dyn_results_value'.tr(
                    namedArgs: {
                      'count': '${orders.length}',
                      'value': totalValue.toStringAsFixed(0),
                    },
                  ),
                  style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Column(
              children: [
                Text(
                  '${orders.length}',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text('ui_183'.tr(), style: TextStyle(color: Colors.white38, fontSize: 8.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final String allLabel;
  final List<String> values;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  _FilterDropdown({
    required this.label,
    required this.value,
    required this.allLabel,
    required this.values,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value ?? '__all__',
      isExpanded: true,
      dropdownColor: Color(0xFF202222),
      icon: Icon(Icons.keyboard_arrow_down_rounded),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 19.r),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.045),
        contentPadding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 11.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      items: [
        DropdownMenuItem<String>(value: '__all__', child: Text(allLabel)),
        ...values.map(
          (item) => DropdownMenuItem<String>(
            value: item,
            child: Text(item.localized),
          ),
        ),
      ],
      onChanged: (selected) => onChanged(
        selected == '__all__' ? null : selected,
      ),
    );
  }
}
