part of 'transaction_bloc.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

final class LoadAllTransactionsEvent extends TransactionEvent {
  const LoadAllTransactionsEvent();
}

final class LoadMyTransactionsEvent extends TransactionEvent {
  const LoadMyTransactionsEvent();
}

final class LoadUserTransactionsEvent extends TransactionEvent {
  final int userId;

  const LoadUserTransactionsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

final class LoadOrderTransactionsEvent extends TransactionEvent {
  final int orderId;

  const LoadOrderTransactionsEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

final class LoadTransactionDetailsEvent extends TransactionEvent {
  final int transactionId;

  const LoadTransactionDetailsEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

final class CreateTransactionEvent extends TransactionEvent {
  final TransactionRequest request;

  const CreateTransactionEvent(this.request);

  @override
  List<Object?> get props => [request];
}

final class UpdateTransactionEvent extends TransactionEvent {
  final int transactionId;
  final TransactionRequest request;

  const UpdateTransactionEvent({
    required this.transactionId,
    required this.request,
  });

  @override
  List<Object?> get props => [transactionId, request];
}

final class DeleteTransactionEvent extends TransactionEvent {
  final int transactionId;

  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

final class ResetTransactionFeedbackEvent extends TransactionEvent {
  const ResetTransactionFeedbackEvent();
}
