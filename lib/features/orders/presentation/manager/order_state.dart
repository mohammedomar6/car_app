part of 'order_bloc.dart';

enum OrderRequestStatus { initial, loading, success, failure }

class OrderState extends Equatable {
  final OrderRequestStatus myOrdersStatus;
  final OrderRequestStatus adminOrdersStatus;
  final OrderRequestStatus detailsStatus;
  final OrderRequestStatus submitStatus;
  final OrderRequestStatus actionStatus;
  final OrderRequestStatus availabilityStatus;
  final List<OrderModel> myOrders;
  final List<OrderModel> adminOrders;
  final OrderModel? selectedOrder;
  final OrderAvailability? availability;
  final OrderOperationResponse? operationResponse;
  final int? processingOrderId;
  final String? submittingType;
  final String? adminStatusFilter;
  final String? adminTypeFilter;
  final String message;
  final String errorMessage;

  const OrderState({
    this.myOrdersStatus = OrderRequestStatus.initial,
    this.adminOrdersStatus = OrderRequestStatus.initial,
    this.detailsStatus = OrderRequestStatus.initial,
    this.submitStatus = OrderRequestStatus.initial,
    this.actionStatus = OrderRequestStatus.initial,
    this.availabilityStatus = OrderRequestStatus.initial,
    this.myOrders = const [],
    this.adminOrders = const [],
    this.selectedOrder,
    this.availability,
    this.operationResponse,
    this.processingOrderId,
    this.submittingType,
    this.adminStatusFilter,
    this.adminTypeFilter,
    this.message = '',
    this.errorMessage = '',
  });

  OrderState copyWith({
    OrderRequestStatus? myOrdersStatus,
    OrderRequestStatus? adminOrdersStatus,
    OrderRequestStatus? detailsStatus,
    OrderRequestStatus? submitStatus,
    OrderRequestStatus? actionStatus,
    OrderRequestStatus? availabilityStatus,
    List<OrderModel>? myOrders,
    List<OrderModel>? adminOrders,
    OrderModel? selectedOrder,
    OrderAvailability? availability,
    OrderOperationResponse? operationResponse,
    int? processingOrderId,
    String? submittingType,
    String? adminStatusFilter,
    String? adminTypeFilter,
    String? message,
    String? errorMessage,
    bool clearAvailability = false,
    bool clearOperationResponse = false,
    bool clearProcessingOrderId = false,
    bool clearAdminStatusFilter = false,
    bool clearAdminTypeFilter = false,
  }) {
    return OrderState(
      myOrdersStatus: myOrdersStatus ?? this.myOrdersStatus,
      adminOrdersStatus: adminOrdersStatus ?? this.adminOrdersStatus,
      detailsStatus: detailsStatus ?? this.detailsStatus,
      submitStatus: submitStatus ?? this.submitStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      myOrders: myOrders ?? this.myOrders,
      adminOrders: adminOrders ?? this.adminOrders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      availability: clearAvailability ? null : availability ?? this.availability,
      operationResponse: clearOperationResponse
          ? null
          : operationResponse ?? this.operationResponse,
      processingOrderId: clearProcessingOrderId
          ? null
          : processingOrderId ?? this.processingOrderId,
      submittingType: submittingType ?? this.submittingType,
      adminStatusFilter: clearAdminStatusFilter
          ? null
          : adminStatusFilter ?? this.adminStatusFilter,
      adminTypeFilter: clearAdminTypeFilter
          ? null
          : adminTypeFilter ?? this.adminTypeFilter,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        myOrdersStatus,
        adminOrdersStatus,
        detailsStatus,
        submitStatus,
        actionStatus,
        availabilityStatus,
        myOrders,
        adminOrders,
        selectedOrder,
        availability,
        operationResponse,
        processingOrderId,
        submittingType,
        adminStatusFilter,
        adminTypeFilter,
        message,
        errorMessage,
      ];
}
