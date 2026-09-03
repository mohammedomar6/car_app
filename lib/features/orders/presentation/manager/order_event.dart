part of 'order_bloc.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

final class CreateRentOrderEvent extends OrderEvent {
  final RentOrderRequest request;

  const CreateRentOrderEvent(this.request);

  @override
  List<Object?> get props => [request];
}

final class CreateBuyOrderEvent extends OrderEvent {
  final BuyOrderRequest request;

  const CreateBuyOrderEvent(this.request);

  @override
  List<Object?> get props => [request];
}

final class CreateInstallmentOrderEvent extends OrderEvent {
  final InstallmentOrderRequest request;

  const CreateInstallmentOrderEvent(this.request);

  @override
  List<Object?> get props => [request];
}

final class LoadMyOrdersEvent extends OrderEvent {
  const LoadMyOrdersEvent();
}

final class LoadAdminOrdersEvent extends OrderEvent {
  final String? status;
  final String? type;

  const LoadAdminOrdersEvent({this.status, this.type});

  @override
  List<Object?> get props => [status, type];
}

final class LoadOrderDetailsEvent extends OrderEvent {
  final int orderId;

  const LoadOrderDetailsEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

final class ReviewOrderEvent extends OrderEvent {
  final ReviewOrderRequest request;

  const ReviewOrderEvent(this.request);

  @override
  List<Object?> get props => [request];
}

final class CancelOrderEvent extends OrderEvent {
  final int orderId;

  const CancelOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

final class CheckOrderAvailabilityEvent extends OrderEvent {
  final int carId;
  final String orderType;
  final DateTime? startDate;
  final DateTime? endDate;

  const CheckOrderAvailabilityEvent({
    required this.carId,
    required this.orderType,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [carId, orderType, startDate, endDate];
}

final class ClearOrderAvailabilityEvent extends OrderEvent {
  const ClearOrderAvailabilityEvent();
}

final class ResetOrderFeedbackEvent extends OrderEvent {
  const ResetOrderFeedbackEvent();
}
