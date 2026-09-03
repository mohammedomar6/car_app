import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class OrderRequest extends Equatable {
  final int carId;
  final List<XFile> documents;

  const OrderRequest({required this.carId, required this.documents});

  Map<String, String> toMultipartFields();
}

class RentOrderRequest extends OrderRequest {
  final String userNotes;
  final DateTime startDate;
  final DateTime endDate;

  const RentOrderRequest({
    required super.carId,
    required this.userNotes,
    required this.startDate,
    required this.endDate,
    required super.documents,
  });

  @override
  Map<String, String> toMultipartFields() => {
        'CarId': carId.toString(),
        'UserNotes': userNotes,
        'StartDate': startDate.toIso8601String(),
        'EndDate': endDate.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        carId,
        userNotes,
        startDate,
        endDate,
        documents.map((document) => document.path).toList(),
      ];
}

class BuyOrderRequest extends OrderRequest {
  final String userNotes;

  const BuyOrderRequest({
    required super.carId,
    required this.userNotes,
    required super.documents,
  });

  @override
  Map<String, String> toMultipartFields() => {
        'CarId': carId.toString(),
        'UserNotes': userNotes,
      };

  @override
  List<Object?> get props => [
        carId,
        userNotes,
        documents.map((document) => document.path).toList(),
      ];
}

class InstallmentOrderRequest extends OrderRequest {
  final int installmentMonths;
  final String notes;

  const InstallmentOrderRequest({
    required super.carId,
    required this.installmentMonths,
    required this.notes,
    required super.documents,
  });

  @override
  Map<String, String> toMultipartFields() => {
        'CarId': carId.toString(),
        'InstallmentMonths': installmentMonths.toString(),
        'Notes': notes,
      };

  @override
  List<Object?> get props => [
        carId,
        installmentMonths,
        notes,
        documents.map((document) => document.path).toList(),
      ];
}

class ReviewOrderRequest extends Equatable {
  final int orderId;
  final String status;
  final String adminNotes;

  const ReviewOrderRequest({
    required this.orderId,
    required this.status,
    required this.adminNotes,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'status': status,
        'adminNotes': adminNotes,
      };

  @override
  List<Object?> get props => [orderId, status, adminNotes];
}
