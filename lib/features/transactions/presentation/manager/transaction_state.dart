part of 'transaction_bloc.dart';

enum TransactionRequestStatus { initial, loading, success, failure }

enum TransactionListScope { all, mine, user, order }

class TransactionState extends Equatable {
  final TransactionRequestStatus listStatus;
  final TransactionRequestStatus detailsStatus;
  final TransactionRequestStatus submitStatus;
  final TransactionRequestStatus actionStatus;
  final List<TransactionModel> transactions;
  final TransactionModel? selectedTransaction;
  final TransactionOperationResponse? operationResponse;
  final TransactionListScope scope;
  final int? scopeId;
  final int? processingTransactionId;
  final String message;
  final String errorMessage;

  const TransactionState({
    this.listStatus = TransactionRequestStatus.initial,
    this.detailsStatus = TransactionRequestStatus.initial,
    this.submitStatus = TransactionRequestStatus.initial,
    this.actionStatus = TransactionRequestStatus.initial,
    this.transactions = const [],
    this.selectedTransaction,
    this.operationResponse,
    this.scope = TransactionListScope.all,
    this.scopeId,
    this.processingTransactionId,
    this.message = '',
    this.errorMessage = '',
  });

  TransactionState copyWith({
    TransactionRequestStatus? listStatus,
    TransactionRequestStatus? detailsStatus,
    TransactionRequestStatus? submitStatus,
    TransactionRequestStatus? actionStatus,
    List<TransactionModel>? transactions,
    TransactionModel? selectedTransaction,
    TransactionOperationResponse? operationResponse,
    TransactionListScope? scope,
    int? scopeId,
    int? processingTransactionId,
    String? message,
    String? errorMessage,
    bool clearSelectedTransaction = false,
    bool clearOperationResponse = false,
    bool clearScopeId = false,
    bool clearProcessingTransactionId = false,
  }) {
    return TransactionState(
      listStatus: listStatus ?? this.listStatus,
      detailsStatus: detailsStatus ?? this.detailsStatus,
      submitStatus: submitStatus ?? this.submitStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      transactions: transactions ?? this.transactions,
      selectedTransaction: clearSelectedTransaction
          ? null
          : selectedTransaction ?? this.selectedTransaction,
      operationResponse: clearOperationResponse
          ? null
          : operationResponse ?? this.operationResponse,
      scope: scope ?? this.scope,
      scopeId: clearScopeId ? null : scopeId ?? this.scopeId,
      processingTransactionId: clearProcessingTransactionId
          ? null
          : processingTransactionId ?? this.processingTransactionId,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        listStatus,
        detailsStatus,
        submitStatus,
        actionStatus,
        transactions,
        selectedTransaction,
        operationResponse,
        scope,
        scopeId,
        processingTransactionId,
        message,
        errorMessage,
      ];
}
