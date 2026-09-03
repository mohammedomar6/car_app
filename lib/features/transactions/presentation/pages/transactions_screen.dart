import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/localization/localized_value.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/orders/presentation/utils/order_details_arguments.dart';
import 'package:car_app/features/orders/presentation/utils/order_car_navigation.dart';
import 'package:car_app/features/transactions/data/models/transaction_model.dart';
import 'package:car_app/features/transactions/presentation/manager/transaction_bloc.dart';
import 'package:car_app/features/transactions/presentation/widgets/transaction_widgets.dart';
import 'package:car_app/features/transactions/presentation/utils/transaction_route_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionsScreen extends StatefulWidget {
  final bool isAdmin;
  final int? initialOrderId;

  TransactionsScreen({
    super.key,
    this.isAdmin = false,
    this.initialOrderId,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  static const _statuses = [
    'All',
    'Completed',
    'Pending',
    'Refunded',
    'Failed',
  ];
  static const _types = [
    'All',
    'Deposit',
    'FullPayment',
    'InstallmentPayment',
  ];

  final _scopeIdController = TextEditingController();
  TransactionListScope _adminScope = TransactionListScope.all;
  String _status = 'All';
  String _type = 'All';

  @override
  void initState() {
    super.initState();
    if (widget.initialOrderId != null) {
      _adminScope = TransactionListScope.order;
      _scopeIdController.text = '${widget.initialOrderId}';
    }
    _load();
  }

  @override
  void dispose() {
    _scopeIdController.dispose();
    super.dispose();
  }

  void _load() {
    final bloc = context.read<TransactionBloc>();
    if (!widget.isAdmin) {
      if (widget.initialOrderId != null) {
        bloc.add(LoadOrderTransactionsEvent(widget.initialOrderId!));
      } else {
        bloc.add(LoadMyTransactionsEvent());
      }
      return;
    }
    final id = int.tryParse(_scopeIdController.text.trim());
    switch (_adminScope) {
      case TransactionListScope.user:
        if (id != null && id > 0) bloc.add(LoadUserTransactionsEvent(id));
        break;
      case TransactionListScope.order:
        if (id != null && id > 0) bloc.add(LoadOrderTransactionsEvent(id));
        break;
      case TransactionListScope.all:
      case TransactionListScope.mine:
        bloc.add(LoadAllTransactionsEvent());
        break;
    }
  }

  void _applyScope() {
    if (_adminScope != TransactionListScope.all) {
      final id = int.tryParse(_scopeIdController.text.trim());
      if (id == null || id <= 0) {
        _showSnack('dyn_valid_scope_id'.tr(namedArgs: {
          'scope': (_adminScope == TransactionListScope.user
                  ? 'scope_user'
                  : 'scope_order')
              .tr(),
        }), isError: true);
        return;
      }
    }
    FocusScope.of(context).unfocus();
    _load();
  }

  Future<void> _refresh() async {
    final bloc = context.read<TransactionBloc>();
    _load();
    await bloc.stream.firstWhere(
      (state) => state.listStatus != TransactionRequestStatus.loading,
    );
  }

  List<TransactionModel> _filtered(List<TransactionModel> items) {
    return items.where((item) {
      final statusMatches = _status == 'All' ||
          item.status.toLowerCase() == _status.toLowerCase();
      final typeMatches = _type == 'All' ||
          item.transactionType.toLowerCase() == _type.toLowerCase();
      return statusMatches && typeMatches;
    }).toList();
  }

  Future<void> _openForm({TransactionModel? transaction}) async {
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
        title: Text('ui_100'.tr()),
        content: Text(
          'dyn_delete_transaction'.tr(
            namedArgs: {'id': '${transaction.transactionId}'},
          ),
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
        } else if (state.actionStatus == TransactionRequestStatus.failure) {
          _showSnack(state.errorMessage, isError: true);
          context.read<TransactionBloc>().add(
                ResetTransactionFeedbackEvent(),
              );
        }
      },
      builder: (context, state) {
        final visible = _filtered(state.transactions);
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.isAdmin ? 'Transaction records' : 'extra_057'.tr()),
            actions: [
              IconButton(
                tooltip: 'ui_210'.tr(),
                onPressed: state.listStatus == TransactionRequestStatus.loading
                    ? null
                    : _load,
                icon: Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          floatingActionButton: widget.isAdmin
              ? FloatingActionButton.extended(
                  onPressed: () => _openForm(),
                  icon: Icon(Icons.add_rounded),
                  label: Text('ui_152'.tr()),
                )
              : null,
          body: Column(
            children: [
              _TransactionsHeader(
                transactions: state.transactions,
                isAdmin: widget.isAdmin,
              ),
              if (widget.isAdmin) _buildAdminScope(),
              _buildLocalFilters(),
              Expanded(child: _buildBody(state, visible)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdminScope() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.075)),
      ),
      child: Column(
        children: [
          SegmentedButton<TransactionListScope>(
            segments: [
              ButtonSegment(
                value: TransactionListScope.all,
                label: Text('ui_016'.tr()),
                icon: Icon(Icons.list_alt_rounded),
              ),
              ButtonSegment(
                value: TransactionListScope.user,
                label: Text('ui_285'.tr()),
                icon: Icon(Icons.person_rounded),
              ),
              ButtonSegment(
                value: TransactionListScope.order,
                label: Text('ui_171'.tr()),
                icon: Icon(Icons.receipt_rounded),
              ),
            ],
            selected: {_adminScope},
            showSelectedIcon: false,
            onSelectionChanged: (selected) {
              setState(() {
                _adminScope = selected.first;
                if (_adminScope == TransactionListScope.all) {
                  _scopeIdController.clear();
                }
              });
              if (_adminScope == TransactionListScope.all) _load();
            },
          ),
          if (_adminScope != TransactionListScope.all) ...[
            SizedBox(height: 10.h),
            TextField(
              controller: _scopeIdController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _applyScope(),
              decoration: InputDecoration(
                labelText: _adminScope == TransactionListScope.user
                    ? 'User ID'
                    : 'Order ID',
                prefixIcon: Icon(
                  _adminScope == TransactionListScope.user
                      ? Icons.person_search_rounded
                      : Icons.manage_search_rounded,
                ),
                suffixIcon: IconButton(
                  onPressed: _applyScope,
                  icon: Icon(Icons.search_rounded),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocalFilters() {
    return SizedBox(
      height: 58.h,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        scrollDirection: Axis.horizontal,
        children: [
          _FilterMenu(
            label: 'dyn_status_filter'.tr(
              namedArgs: {
                'value': (_status == 'All' ? 'All' : _status).localized,
              },
            ),
            icon: Icons.fact_check_outlined,
            selected: _status,
            values: _statuses,
            onSelected: (value) => setState(() => _status = value),
          ),
          SizedBox(width: 9.w),
          _FilterMenu(
            label: 'dyn_type_filter'.tr(
              namedArgs: {
                'value': (_type == 'All' ? 'All' : _type).localized,
              },
            ),
            icon: Icons.account_balance_wallet_outlined,
            selected: _type,
            values: _types,
            onSelected: (value) => setState(() => _type = value),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    TransactionState state,
    List<TransactionModel> transactions,
  ) {
    if (state.listStatus == TransactionRequestStatus.loading &&
        state.transactions.isEmpty) {
      return Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }
    if (state.listStatus == TransactionRequestStatus.failure &&
        state.transactions.isEmpty) {
      return TransactionsEmptyState(
        title: 'ui_084'.tr(),
        subtitle: state.errorMessage,
        onRefresh: _load,
      );
    }
    if (transactions.isEmpty) {
      return TransactionsEmptyState(
        title: widget.isAdmin ? 'extra_060'.tr() : 'extra_058'.tr(),
        subtitle: widget.isAdmin
            ? 'extra_021'.tr()
            : 'extra_028'.tr(),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.secondary,
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 5.h, 16.w, 90.h),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return TransactionCard(
            transaction: transaction,
            isAdmin: widget.isAdmin,
            isProcessing:
                state.actionStatus == TransactionRequestStatus.loading &&
                    state.processingTransactionId == transaction.transactionId,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.transactionDetails,
              arguments: TransactionDetailsArguments(
                transactionId: transaction.transactionId,
                isAdmin: widget.isAdmin,
              ),
            ),
            onViewCar: () => OrderCarNavigation.openCarDetails(
              context,
              transaction.carId,
            ),
            onViewOrder: () => Navigator.pushNamed(
              context,
              AppRoutes.orderDetails,
              arguments: OrderDetailsArguments(
                orderId: transaction.orderId,
                isAdmin: widget.isAdmin,
              ),
            ),
            onEdit: widget.isAdmin
                ? () => _openForm(transaction: transaction)
                : null,
            onDelete: widget.isAdmin ? () => _delete(transaction) : null,
          );
        },
      ),
    );
  }
}

class _TransactionsHeader extends StatelessWidget {
  final List<TransactionModel> transactions;
  final bool isAdmin;

  _TransactionsHeader({
    required this.transactions,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final completed = transactions
        .where((item) => item.status.toLowerCase() == 'completed')
        .length;
    final value = transactions.fold<double>(0, (sum, item) => sum + item.amount);
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.23),
            Color(0xFF151717),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.24)),
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
              Icons.handshake_rounded,
              color: AppColors.secondary,
              size: 27.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAdmin ? 'extra_033'.tr() : 'extra_111'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'dyn_records_total'.tr(
                    namedArgs: {
                      'count': '${transactions.length}',
                      'value': value.toStringAsFixed(0),
                    },
                  ),
                  style: TextStyle(color: Colors.white54, fontSize: 9.sp),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Text(
                  '$completed',
                  style: TextStyle(
                    color: Color(0xFF35C68B),
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text('ui_074'.tr(),
                    style: TextStyle(color: Colors.white38, fontSize: 7.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterMenu extends StatelessWidget {
  final String label;
  final IconData icon;
  final String selected;
  final List<String> values;
  final ValueChanged<String> onSelected;

  _FilterMenu({
    required this.label,
    required this.icon,
    required this.selected,
    required this.values,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
        initialValue: selected,
        onSelected: onSelected,
        itemBuilder: (context) => values
            .map(
              (value) => PopupMenuItem(
                value: value,
                child: Text(value.localized),
              ),
            )
            .toList(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(100.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 17.r, color: AppColors.secondary),
              SizedBox(width: 7.w),
              Text(label, style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
              SizedBox(width: 5.w),
              Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            ],
          ),
        ),
      );
}

String _typeLabel(String value) {
  return value.localized;
}
