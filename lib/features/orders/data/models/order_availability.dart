import 'package:equatable/equatable.dart';

class OrderAvailability extends Equatable {
  final int carId;
  final String orderType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isAvailable;

  const OrderAvailability({
    required this.carId,
    required this.orderType,
    required this.startDate,
    required this.endDate,
    required this.isAvailable,
  });

  factory OrderAvailability.fromJson(Map<String, dynamic> json) {
    final rawCarId = json['carId'];
    return OrderAvailability(
      carId: rawCarId is int
          ? rawCarId
          : int.tryParse(rawCarId?.toString() ?? '') ?? 0,
      orderType: json['orderType']?.toString() ?? '',
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? ''),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? ''),
      isAvailable: json['isAvailable'] == true,
    );
  }

  @override
  List<Object?> get props => [
        carId,
        orderType,
        startDate,
        endDate,
        isAvailable,
      ];
}
