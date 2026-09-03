import 'package:equatable/equatable.dart';

import '../../data/models/car_response_model.dart';
import '../../data/models/car_status_filters.dart';

enum PendingCarsStatus {
  initial,
  loading,
  success,
  failure,
}

class PendingCarsState extends Equatable {
  final PendingCarsStatus status;
  final List<CarResponseModel> cars;
  final CarStatusFilters filters;
  final String message;

  const PendingCarsState({
    this.status = PendingCarsStatus.initial,
    this.cars = const [],
    this.filters = const CarStatusFilters(approvalStatus: 'Pending'),
    this.message = '',
  });

  PendingCarsState copyWith({
    PendingCarsStatus? status,
    List<CarResponseModel>? cars,
    CarStatusFilters? filters,
    String? message,
  }) {
    return PendingCarsState(
      status: status ?? this.status,
      cars: cars ?? this.cars,
      filters: filters ?? this.filters,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [
    status,
    cars,
    filters,
    message,
  ];
}
