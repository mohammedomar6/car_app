import 'package:bloc/bloc.dart';
import 'package:car_app/features/transactions/data/data_sources/transaction_remote_data_source.dart';
import 'package:car_app/features/transactions/data/models/transaction_model.dart';
import 'package:car_app/features/transactions/data/models/transaction_operation_response.dart';
import 'package:car_app/features/transactions/data/models/transaction_request.dart';
import 'package:equatable/equatable.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionBloc(this.remoteDataSource) : super(const TransactionState()) {
    on<LoadAllTransactionsEvent>(_loadAll);
    on<LoadMyTransactionsEvent>(_loadMine);
    on<LoadUserTransactionsEvent>(_loadByUser);
    on<LoadOrderTransactionsEvent>(_loadByOrder);
    on<LoadTransactionDetailsEvent>(_loadDetails);
    on<CreateTransactionEvent>(_create);
    on<UpdateTransactionEvent>(_update);
    on<DeleteTransactionEvent>(_delete);
    on<ResetTransactionFeedbackEvent>(_resetFeedback);
  }

  Future<void> _loadAll(
    LoadAllTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) {
    return _loadList(
      remoteDataSource.getTransactions,
      TransactionListScope.all,
      null,
      emit,
    );
  }

  Future<void> _loadMine(
    LoadMyTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) {
    return _loadList(
      remoteDataSource.getMyTransactions,
      TransactionListScope.mine,
      null,
      emit,
    );
  }

  Future<void> _loadByUser(
    LoadUserTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) {
    return _loadList(
      () => remoteDataSource.getTransactionsByUser(event.userId),
      TransactionListScope.user,
      event.userId,
      emit,
    );
  }

  Future<void> _loadByOrder(
    LoadOrderTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) {
    return _loadList(
      () => remoteDataSource.getTransactionsByOrder(event.orderId),
      TransactionListScope.order,
      event.orderId,
      emit,
    );
  }

  Future<void> _loadList(
    Future<List<TransactionModel>> Function() loader,
    TransactionListScope scope,
    int? scopeId,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(
      listStatus: TransactionRequestStatus.loading,
      scope: scope,
      scopeId: scopeId,
      clearScopeId: scopeId == null,
      errorMessage: '',
    ));
    try {
      final transactions = await loader();
      emit(state.copyWith(
        listStatus: TransactionRequestStatus.success,
        transactions: transactions,
      ));
    } catch (error) {
      emit(state.copyWith(
        listStatus: TransactionRequestStatus.failure,
        errorMessage: _cleanError(error),
      ));
    }
  }

  Future<void> _loadDetails(
    LoadTransactionDetailsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(
      detailsStatus: TransactionRequestStatus.loading,
      errorMessage: '',
    ));
    try {
      final transaction =
          await remoteDataSource.getTransactionById(event.transactionId);
      emit(state.copyWith(
        detailsStatus: TransactionRequestStatus.success,
        selectedTransaction: transaction,
      ));
    } catch (error) {
      emit(state.copyWith(
        detailsStatus: TransactionRequestStatus.failure,
        errorMessage: _cleanError(error),
      ));
    }
  }

  Future<void> _create(
    CreateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    if (state.submitStatus == TransactionRequestStatus.loading) return;
    emit(state.copyWith(
      submitStatus: TransactionRequestStatus.loading,
      message: '',
      errorMessage: '',
      clearOperationResponse: true,
    ));
    try {
      final response = await remoteDataSource.createTransaction(event.request);
      emit(state.copyWith(
        submitStatus: TransactionRequestStatus.success,
        operationResponse: response,
        message: response.message,
      ));
    } catch (error) {
      emit(state.copyWith(
        submitStatus: TransactionRequestStatus.failure,
        errorMessage: _cleanError(error),
      ));
    }
  }

  Future<void> _update(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    if (state.submitStatus == TransactionRequestStatus.loading) return;
    emit(state.copyWith(
      submitStatus: TransactionRequestStatus.loading,
      processingTransactionId: event.transactionId,
      message: '',
      errorMessage: '',
      clearOperationResponse: true,
    ));
    try {
      final response = await remoteDataSource.updateTransaction(
        event.transactionId,
        event.request,
      );
      emit(state.copyWith(
        submitStatus: TransactionRequestStatus.success,
        operationResponse: response,
        message: response.message,
        clearProcessingTransactionId: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        submitStatus: TransactionRequestStatus.failure,
        errorMessage: _cleanError(error),
        clearProcessingTransactionId: true,
      ));
    }
  }

  Future<void> _delete(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    if (state.actionStatus == TransactionRequestStatus.loading) return;
    emit(state.copyWith(
      actionStatus: TransactionRequestStatus.loading,
      processingTransactionId: event.transactionId,
      message: '',
      errorMessage: '',
    ));
    try {
      final response =
          await remoteDataSource.deleteTransaction(event.transactionId);
      final remaining = state.transactions
          .where((item) => item.transactionId != event.transactionId)
          .toList();
      emit(state.copyWith(
        actionStatus: TransactionRequestStatus.success,
        transactions: remaining,
        operationResponse: response,
        message: response.message,
        clearSelectedTransaction:
            state.selectedTransaction?.transactionId == event.transactionId,
        clearProcessingTransactionId: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        actionStatus: TransactionRequestStatus.failure,
        errorMessage: _cleanError(error),
        clearProcessingTransactionId: true,
      ));
    }
  }

  void _resetFeedback(
    ResetTransactionFeedbackEvent event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(
      submitStatus: TransactionRequestStatus.initial,
      actionStatus: TransactionRequestStatus.initial,
      message: '',
      errorMessage: '',
      clearOperationResponse: true,
      clearProcessingTransactionId: true,
    ));
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst(RegExp(r'^(Exception|FormatException):\s*'), '')
        .trim();
  }
}
