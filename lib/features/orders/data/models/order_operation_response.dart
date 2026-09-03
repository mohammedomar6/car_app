import 'package:equatable/equatable.dart';

class OrderOperationResponse extends Equatable {
  final String message;
  final int? id;

  const OrderOperationResponse({required this.message, this.id});

  factory OrderOperationResponse.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['orderId'];
    return OrderOperationResponse(
      message: json['message']?.toString() ?? 'Operation completed successfully.',
      id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? ''),
    );
  }

  @override
  List<Object?> get props => [message, id];
}
