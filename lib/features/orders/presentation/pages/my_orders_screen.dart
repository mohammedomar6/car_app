import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/orders/data/models/order_model.dart';
import 'package:car_app/features/orders/presentation/manager/order_bloc.dart';
import 'package:car_app/features/orders/presentation/utils/order_car_navigation.dart';
import 'package:car_app/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyOrdersScreen extends StatefulWidget {
  MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  static const _filters = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
    'Completed',
    'Canceled',
  ];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(LoadMyOrdersEvent());
  }

  Future<void> _refresh() async {
    final bloc = context.read<OrderBloc>();
    bloc.add(LoadMyOrdersEvent());
    await bloc.stream.firstWhere(
      (state) => state.myOrdersStatus != OrderRequestStatus.loading,
    );
  }

  List<OrderModel> _filteredOrders(List<OrderModel> orders) {
    if (_selectedFilter == 'All') return orders;
    return orders
        .where(
          (order) =>
              order.orderStatus.toLowerCase() == _selectedFilter.toLowerCase(),
        )
        .toList();
  }

  Future<void> _confirmCancel(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB547)),
        title: Text('ui_058'.tr()),
        content: Text(
          'dyn_order_cancel_warning'.tr(
            namedArgs: {'id': '${order.orderId}'},
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('ui_135'.tr()),
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderBloc, OrderState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == OrderRequestStatus.success) {
          _showSnack(state.message);
          context.read<OrderBloc>().add(ResetOrderFeedbackEvent());
        } else if (state.actionStatus == OrderRequestStatus.failure) {
          _showSnack(state.errorMessage, isError: true);
          context.read<OrderBloc>().add(ResetOrderFeedbackEvent());
        }
      },
      builder: (context, state) {
        final orders = _filteredOrders(state.myOrders);
        return Scaffold(
          appBar: AppBar(
            title: Text('ui_149'.tr()),
            actions: [
              IconButton(
                tooltip: 'ui_210'.tr(),
                onPressed: state.myOrdersStatus == OrderRequestStatus.loading
                    ? null
                    : () => context
                        .read<OrderBloc>()
                        .add(LoadMyOrdersEvent()),
                icon: Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: Column(
            children: [
              _OrdersHeader(orders: state.myOrders),
              SizedBox(
                height: 58.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final selected = _selectedFilter == filter;
                    return ChoiceChip(
                      selected: selected,
                      label: Text(filter),
                      showCheckmark: false,
                      selectedColor: AppColors.secondary,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      side: BorderSide(
                        color: selected
                            ? AppColors.secondary
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                      labelStyle: TextStyle(
                        color: selected ? Colors.black : Colors.white60,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _selectedFilter = filter),
                    );
                  },
                ),
              ),
              Expanded(child: _buildBody(state, orders)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(OrderState state, List<OrderModel> orders) {
    if (state.myOrdersStatus == OrderRequestStatus.loading &&
        state.myOrders.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }
    if (state.myOrdersStatus == OrderRequestStatus.failure &&
        state.myOrders.isEmpty) {
      return OrdersEmptyState(
        title: 'ui_085'.tr(),
        subtitle: state.errorMessage,
        onRefresh: () =>
            context.read<OrderBloc>().add(LoadMyOrdersEvent()),
      );
    }
    if (orders.isEmpty) {
      return OrdersEmptyState(
        title: _selectedFilter == 'All'
            ? 'extra_062'.tr()
            : 'No $_selectedFilter orders',
        subtitle: _selectedFilter == 'All'
            ? 'extra_110'.tr()
            : 'extra_104'.tr(),
      );
    }

    return RefreshIndicator(
      color: AppColors.secondary,
      onRefresh: _refresh,
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 25.h),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(
            order: order,
            isProcessing: state.actionStatus == OrderRequestStatus.loading &&
                state.processingOrderId == order.orderId,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.orderDetails,
              arguments: order.orderId,
            ),
            onViewCar: () => OrderCarNavigation.openCarDetails(
              context,
              order.carId,
            ),
            onCancel: order.orderStatus.toLowerCase() == 'pending'
                ? () => _confirmCancel(order)
                : null,
          );
        },
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  final List<OrderModel> orders;

  _OrdersHeader({required this.orders});

  @override
  Widget build(BuildContext context) {
    final pending = orders
        .where((order) => order.orderStatus.toLowerCase() == 'pending')
        .length;
    final approved = orders
        .where((order) => order.orderStatus.toLowerCase() == 'approved')
        .length;
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 4.h),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.22),
            Color(0xFF161818),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ui_264'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5.h),
                Text('ui_123'.tr(),
                  style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                ),
              ],
            ),
          ),
          _HeaderCount(label: 'ui_194'.tr(), value: pending),
          SizedBox(width: 8.w),
          _HeaderCount(label: 'ui_034'.tr(), value: approved),
        ],
      ),
    );
  }
}

class _HeaderCount extends StatelessWidget {
  final String label;
  final int value;

  _HeaderCount({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55.w,
      padding: EdgeInsets.symmetric(vertical: 9.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(label, style: TextStyle(color: Colors.white38, fontSize: 7.sp)),
        ],
      ),
    );
  }
}
