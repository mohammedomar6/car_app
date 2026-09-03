import 'package:equatable/equatable.dart';
import '../../../data/models/approve_response_model.dart';

enum ApproveCarStatus {
  initial,
  loading,
  success,
  failure,
}

class ApproveCarState extends Equatable {
  final ApproveCarStatus status;
  final ApproveResponseModel? response;
  final int? processingCarId;
  final String? action;
  final String message;

  const ApproveCarState({
    this.status = ApproveCarStatus.initial,
    this.response,
    this.processingCarId,
    this.action,
    this.message = '',
  });

  ApproveCarState copyWith({
    ApproveCarStatus? status,
    ApproveResponseModel? response,
    int? processingCarId,
    String? action,
    String? message,
    bool clearProcessingCarId = false,
    bool clearAction = false,
  }) {
    return ApproveCarState(
      status: status ?? this.status,
      response: response ?? this.response,
      processingCarId:
          clearProcessingCarId ? null : processingCarId ?? this.processingCarId,
      action: clearAction ? null : action ?? this.action,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    response,
    processingCarId,
    action,
    message,
  ];
}
