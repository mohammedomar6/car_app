import 'package:equatable/equatable.dart';
import '../../data/models/car_status_filters.dart';

abstract class PendingCarsEvent extends Equatable {
  const PendingCarsEvent();

  @override
  List<Object> get props => [];
}

class GetPendingCarsEvent extends PendingCarsEvent {
  final CarStatusFilters filters;

  const GetPendingCarsEvent({
    this.filters = const CarStatusFilters(approvalStatus: 'Pending'),
  });

  @override
  List<Object> get props => [filters];
}
