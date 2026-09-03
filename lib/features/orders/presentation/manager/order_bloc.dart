import 'package:bloc/bloc.dart';
import 'package:car_app/features/orders/data/data_sources/order_remote_data_source.dart';
import 'package:car_app/features/orders/data/models/order_availability.dart';
import 'package:car_app/features/orders/data/models/order_model.dart';
import 'package:car_app/features/orders/data/models/order_operation_response.dart';
import 'package:car_app/features/orders/data/models/order_requests.dart';
import 'package:equatable/equatable.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRemoteDataSource remoteDataSource;

  OrderBloc(this.remoteDataSource) : super(const OrderState()) {
    on<CreateRentOrderEvent>(_createRentOrder);
    on<CreateBuyOrderEvent>(_createBuyOrder);
    on<CreateInstallmentOrderEvent>(_createInstallmentOrder);
    on<LoadMyOrdersEvent>(_loadMyOrders);
    on<LoadAdminOrdersEvent>(_loadAdminOrders);
    on<LoadOrderDetailsEvent>(_loadOrderDetails);
    on<ReviewOrderEvent>(_reviewOrder);
    on<CancelOrderEvent>(_cancelOrder);
    on<CheckOrderAvailabilityEvent>(_checkAvailability);
    on<ClearOrderAvailabilityEvent>(_clearAvailability);
    on<ResetOrderFeedbackEvent>(_resetFeedback);
  }

  Future<void> _createRentOrder(
    CreateRentOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state.submitStatus == OrderRequestStatus.loading) return;
    emit(state.copyWith(
      submitStatus: OrderRequestStatus.loading,
      submittingType: 'Rent',
      errorMessage: '',
      message: '',
    ));
    try {
      final response = await remoteDataSource.createRentOrder(event.request);
      emit(state.copyWith(
        submitStatus: OrderRequestStatus.success,
        operationResponse: response,
        message: response.message,
      ));
    } catch (error) {
      emit(state.copyWith(
        submitStatus: OrderRequestStatus.failure,
        errorMessage: _cleanError(error),
      ));
    }
  }

  Future<void> _createBuyOrder(
    CreateBuyOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state.submitStatus == OrderRequestStatus.loading) return;
    emit(state.copyWith(
      submitStatus: OrderRequestStatus.loading,
      submittingType: 'Buy',
      errorMessage: '',
      message: '',
    ));
    try {
      final response = await remoteDataSource.createBuyOrder(event.request);
      emit(state.copyWith(
        submitStatus: OrderRequestStatus.success,
        operationResponse: response,
        message: response.message,
      ));
    } catch (error) {
      emit(state.copyWith(
        submitStatus: OrderRequestStatus.failure,
        errorMessage: _cleanError(error),
      ));
    }
  }

  Future<void> _createInstallmentOrder(
    CreateInstallmentOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state.submitStatus == OrderRequestStatus.loading) return;
    emit(state.copyWith(
      submitStatus: OrderRequestStatus.loading,
      submittingType: 'Installment',
      errorMessage: '',
      message: '',
    ));
    try {
      final response = await remoteDataSource.createInstallmentOrder(
        event.request,
      );
      emit(state.copyWith(
        submitStatus: OrderRequestStatus.success,
        operationResponse: response,
        message: response.message,
      ));
    } catch (error) {
      emit(state.copyWith(
        submitStatus: OrderRequestStatus.failure,
        errorMessage: _cleanError(error),
      ));
    }
  }

  Future<void> _loadMyOrders(
    LoadMyOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(
      myOrdersStatus: OrderRequestStatus.loading,
      errorMessage: '',
    ));
    try {
      final orders = await remoteDataSource.getMyOrders();
      emit(state.copyWith(
        myOrdersStatus: OrderRequestStatus.success,
        myOrders: orders,
      ));
    } catch (error) {
      emit(state.copyWith(
        myOrdersStatus: OrderRequestStatus.failure,
        errorMessage: _cleanError(error),
      ));
    }
  }

  Future<void> _loadAdminOrders(
    LoadAdminOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(
      adminOrdersStatus: OrderRequestStatus.loading,
      adminStatusFilter: event.status,
      adminTypeFilter: event.type,
      clearAdminStatusFilter: event.status == null,
      clearAdminTypeFilter: event.type == null,
      errorMessage: '',
    ));
    try {
      final orders = await remoteDataSource.getAdminOrders(
        status: event.status,
        type: event.type,
      );
      emit(state.copyWith(
        adminOrdersStatus: OrderRequestStatus.success,
        adminOrders: orders,
      ));
    } catch (error) {
      emit(state.copyWith(
        adminOrdersStatus: OrderRequestStatus.failure,
        errorMessage: _cleanError(error),
      ));
    }
  }

  Future<void> _loadOrderDetails(
    LoadOrderDetailsEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(
      detailsStatus: OrderRequestStatus.loading,
      errorMessage: '',
    ));
    try {
      var order = await remoteDataSource.getOrderById(event.orderId);
      if (order.sellerId == null) {
        for (final cachedOrder in state.adminOrders) {
          if (cachedOrder.orderId == event.orderId &&
              cachedOrder.sellerId != null) {
            order = order.copyWith(sellerId: cachedOrder.sellerId);
            break;
          }
        }
      }
      emit(state.copyWith(
        detailsStatus: OrderRequestStatus.success,
        selectedOrder: order,
      ));
    } catch (error) {
      emit(state.copyWith(
        detailsStatus: OrderRequestStatus.failure,
        errorMessage: _cleanError(error),
      ));
    }
  }

  Future<void> _reviewOrder(
    ReviewOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state.actionStatus == OrderRequestStatus.loading) return;
    emit(state.copyWith(
      actionStatus: OrderRequestStatus.loading,
      processingOrderId: event.request.orderId,
      errorMessage: '',
      message: '',
    ));
    try {
      final response = await remoteDataSource.reviewOrder(event.request);
      final updatedAdminOrders = state.adminOrders.map((order) {
        if (order.orderId != event.request.orderId) return order;
        return order.copyWith(
          orderStatus: event.request.status,
          adminNotes: event.request.adminNotes,
        );
      }).toList();
      final selected = state.selectedOrder?.orderId == event.request.orderId
          ? state.selectedOrder!.copyWith(
              orderStatus: event.request.status,
              adminNotes: event.request.adminNotes,
            )
          : state.selectedOrder;
      emit(state.copyWith(
        actionStatus: OrderRequestStatus.success,
        operationResponse: response,
        adminOrders: updatedAdminOrders,
        selectedOrder: selected,
        message: response.message,
        clearProcessingOrderId: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        actionStatus: OrderRequestStatus.failure,
        errorMessage: _cleanError(error),
        clearProcessingOrderId: true,
      ));
    }
  }

  Future<void> _cancelOrder(
    CancelOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state.actionStatus == OrderRequestStatus.loading) return;
    emit(state.copyWith(
      actionStatus: OrderRequestStatus.loading,
      processingOrderId: event.orderId,
      errorMessage: '',
      message: '',
    ));
    try {
      final response = await remoteDataSource.cancelOrder(event.orderId);
      final updatedOrders = state.myOrders.map((order) {
        return order.orderId == event.orderId
            ? order.copyWith(orderStatus: 'Canceled')
            : order;
      }).toList();
      final selected = state.selectedOrder?.orderId == event.orderId
          ? state.selectedOrder!.copyWith(orderStatus: 'Canceled')
          : state.selectedOrder;
      emit(state.copyWith(
        actionStatus: OrderRequestStatus.success,
        operationResponse: response,
        myOrders: updatedOrders,
        selectedOrder: selected,
        message: response.message,
        clearProcessingOrderId: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        actionStatus: OrderRequestStatus.failure,
        errorMessage: _cleanError(error),
        clearProcessingOrderId: true,
      ));
    }
  }

  Future<void> _checkAvailability(
    CheckOrderAvailabilityEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state.availabilityStatus == OrderRequestStatus.loading) return;
    emit(state.copyWith(
      availabilityStatus: OrderRequestStatus.loading,
      clearAvailability: true,
      errorMessage: '',
    ));
    try {
      final availability = await remoteDataSource.checkAvailability(
        carId: event.carId,
        orderType: event.orderType,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(state.copyWith(
        availabilityStatus: OrderRequestStatus.success,
        availability: availability,
      ));
    } catch (error) {
      emit(state.copyWith(
        availabilityStatus: OrderRequestStatus.failure,
        errorMessage: _cleanError(error),
      ));
    }
  }

  void _clearAvailability(
    ClearOrderAvailabilityEvent event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(
      availabilityStatus: OrderRequestStatus.initial,
      clearAvailability: true,
    ));
  }

  void _resetFeedback(
    ResetOrderFeedbackEvent event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(
      submitStatus: OrderRequestStatus.initial,
      actionStatus: OrderRequestStatus.initial,
      message: '',
      errorMessage: '',
      clearOperationResponse: true,
      clearProcessingOrderId: true,
    ));
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}
