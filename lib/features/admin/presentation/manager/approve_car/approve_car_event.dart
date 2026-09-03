import 'package:equatable/equatable.dart';
import '../../../data/models/approve_request_model.dart';
import '../../../data/models/reject_car_request_model.dart';

abstract class ApproveCarEvent extends Equatable {
  const ApproveCarEvent();

  @override
  List<Object> get props => [];
}

class ApproveCar extends ApproveCarEvent {
  final ApproveRequestModel request;

  const ApproveCar({
    required this.request,
  });

  @override
  List<Object> get props => [request];
}

class RejectCar extends ApproveCarEvent {
  final RejectCarRequestModel request;

  const RejectCar({required this.request});

  @override
  List<Object> get props => [request];
}
