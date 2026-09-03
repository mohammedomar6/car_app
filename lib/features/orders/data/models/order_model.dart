import 'package:equatable/equatable.dart';

class OrderModel extends Equatable {
  final int orderId;
  final int userId;
  final int? sellerId;
  final int carId;
  final String orderType;
  final String orderStatus;
  final double totalPrice;
  final String userNotes;
  final String? adminNotes;
  final DateTime createdAt;
  final List<String> documentUrls;
  final RentDetails? rentDetails;
  final InstallmentDetails? installmentDetails;

  const OrderModel({
    required this.orderId,
    required this.userId,
    required this.sellerId,
    required this.carId,
    required this.orderType,
    required this.orderStatus,
    required this.totalPrice,
    required this.userNotes,
    required this.adminNotes,
    required this.createdAt,
    required this.documentUrls,
    required this.rentDetails,
    required this.installmentDetails,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawDocuments = json['documentUrls'] ?? json['documents'];
    final rentJson = json['rentDetails'];
    final installmentJson = json['installmentDetails'];

    return OrderModel(
      orderId: _asInt(json['orderId'] ?? json['id']),
      userId: _asInt(json['userId']),
      sellerId: _asNullableInt(json['sellerId']),
      carId: _asInt(json['carId']),
      orderType: json['orderType']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? '',
      totalPrice: _asDouble(json['totalPrice']),
      userNotes: json['userNotes']?.toString() ?? '',
      adminNotes: json['adminNotes']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      documentUrls: rawDocuments is List
          ? rawDocuments
              .where((document) => document != null)
              .map((document) => document.toString())
              .toList()
          : const [],
      rentDetails: rentJson is Map
          ? RentDetails.fromJson(Map<String, dynamic>.from(rentJson))
          : null,
      installmentDetails: installmentJson is Map
          ? InstallmentDetails.fromJson(
              Map<String, dynamic>.from(installmentJson),
            )
          : null,
    );
  }

  OrderModel copyWith({
    int? sellerId,
    String? orderStatus,
    String? adminNotes,
  }) {
    return OrderModel(
      orderId: orderId,
      userId: userId,
      sellerId: sellerId ?? this.sellerId,
      carId: carId,
      orderType: orderType,
      orderStatus: orderStatus ?? this.orderStatus,
      totalPrice: totalPrice,
      userNotes: userNotes,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt,
      documentUrls: documentUrls,
      rentDetails: rentDetails,
      installmentDetails: installmentDetails,
    );
  }

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'userId': userId,
        'sellerId': sellerId,
        'carId': carId,
        'orderType': orderType,
        'orderStatus': orderStatus,
        'totalPrice': totalPrice,
        'userNotes': userNotes,
        'adminNotes': adminNotes,
        'createdAt': createdAt.toIso8601String(),
        'documentUrls': documentUrls,
        'rentDetails': rentDetails?.toJson(),
        'installmentDetails': installmentDetails?.toJson(),
      };

  @override
  List<Object?> get props => [
        orderId,
        userId,
        sellerId,
        carId,
        orderType,
        orderStatus,
        totalPrice,
        userNotes,
        adminNotes,
        createdAt,
        documentUrls,
        rentDetails,
        installmentDetails,
      ];
}

class RentDetails extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;

  const RentDetails({required this.startDate, required this.endDate});

  factory RentDetails.fromJson(Map<String, dynamic> json) => RentDetails(
        startDate: DateTime.tryParse(json['startDate']?.toString() ?? ''),
        endDate: DateTime.tryParse(json['endDate']?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      };

  @override
  List<Object?> get props => [startDate, endDate];
}

class InstallmentDetails extends Equatable {
  final int installmentMonths;
  final double? monthlyPayment;
  final double? downPayment;
  final DateTime? firstPaymentDate;

  const InstallmentDetails({
    required this.installmentMonths,
    this.monthlyPayment,
    this.downPayment,
    this.firstPaymentDate,
  });

  factory InstallmentDetails.fromJson(Map<String, dynamic> json) {
    return InstallmentDetails(
      installmentMonths: _asInt(
        json['installmentMonths'] ?? json['months'] ?? json['numberOfMonths'],
      ),
      monthlyPayment: _asNullableDouble(
        json['monthlyPayment'] ?? json['monthlyAmount'],
      ),
      downPayment: _asNullableDouble(
        json['downPayment'] ?? json['initialPayment'],
      ),
      firstPaymentDate: DateTime.tryParse(
        json['firstPaymentDate']?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'installmentMonths': installmentMonths,
        'monthlyPayment': monthlyPayment,
        'downPayment': downPayment,
        'firstPaymentDate': firstPaymentDate?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        installmentMonths,
        monthlyPayment,
        downPayment,
        firstPaymentDate,
      ];
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
