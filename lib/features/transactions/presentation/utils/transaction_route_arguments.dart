import 'package:car_app/features/orders/data/models/order_model.dart';
import 'package:car_app/features/transactions/data/models/transaction_model.dart';

class TransactionFormArguments {
  final OrderModel? order;
  final TransactionModel? transaction;

  const TransactionFormArguments({this.order, this.transaction});
}

class TransactionsScreenArguments {
  final bool isAdmin;
  final int? initialOrderId;

  const TransactionsScreenArguments({
    this.isAdmin = false,
    this.initialOrderId,
  });
}

class TransactionDetailsArguments {
  final int transactionId;
  final bool isAdmin;

  const TransactionDetailsArguments({
    required this.transactionId,
    this.isAdmin = false,
  });
}
