import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final int transactionId;
  final int orderId;
  final int buyerId;
  final int sellerId;
  final int carId;
  final String orderStatus;
  final double amount;
  final String paymentMethod;
  final String transactionType;
  final String status;
  final String referenceNumber;
  final String notes;
  final List<ContractImageModel> contractImages;
  final int? createdBy;
  final DateTime? createdAt;
  final int? updatedBy;
  final DateTime? updatedAt;

  const TransactionModel({
    required this.transactionId,
    required this.orderId,
    required this.buyerId,
    required this.sellerId,
    required this.carId,
    required this.orderStatus,
    required this.amount,
    required this.paymentMethod,
    required this.transactionType,
    required this.status,
    required this.referenceNumber,
    required this.notes,
    required this.contractImages,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['contractImages'];
    return TransactionModel(
      transactionId: _asInt(json['transactionId'] ?? json['id']),
      orderId: _asInt(json['orderId']),
      buyerId: _asInt(json['buyerId']),
      sellerId: _asInt(json['sellerId']),
      carId: _asInt(json['carId']),
      orderStatus: json['orderStatus']?.toString() ?? '',
      amount: _asDouble(json['amount']),
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      transactionType: json['transactionType']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      referenceNumber: json['referenceNumber']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      contractImages: rawImages is List
          ? rawImages.map((item) {
              if (item is Map) {
                return ContractImageModel.fromJson(
                  Map<String, dynamic>.from(item),
                );
              }
              return ContractImageModel(
                imageId: 0,
                imageUrl: item?.toString() ?? '',
                uploadedAt: null,
              );
            }).where((image) => image.imageUrl.isNotEmpty).toList()
          : const [],
      createdBy: _asNullableInt(json['createdBy']),
      createdAt: _asDate(json['createdAt']),
      updatedBy: _asNullableInt(json['updatedBy']),
      updatedAt: _asDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'transactionId': transactionId,
        'orderId': orderId,
        'buyerId': buyerId,
        'sellerId': sellerId,
        'carId': carId,
        'orderStatus': orderStatus,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'transactionType': transactionType,
        'status': status,
        'referenceNumber': referenceNumber,
        'notes': notes,
        'contractImages': contractImages.map((image) => image.toJson()).toList(),
        'createdBy': createdBy,
        'createdAt': createdAt?.toIso8601String(),
        'updatedBy': updatedBy,
        'updatedAt': updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        transactionId,
        orderId,
        buyerId,
        sellerId,
        carId,
        orderStatus,
        amount,
        paymentMethod,
        transactionType,
        status,
        referenceNumber,
        notes,
        contractImages,
        createdBy,
        createdAt,
        updatedBy,
        updatedAt,
      ];
}

class ContractImageModel extends Equatable {
  final int imageId;
  final String imageUrl;
  final DateTime? uploadedAt;

  const ContractImageModel({
    required this.imageId,
    required this.imageUrl,
    required this.uploadedAt,
  });

  factory ContractImageModel.fromJson(Map<String, dynamic> json) {
    return ContractImageModel(
      imageId: _asInt(json['imageId'] ?? json['id']),
      imageUrl: (json['imageUrl'] ?? json['url'])?.toString() ?? '',
      uploadedAt: _asDate(json['uploadedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'imageId': imageId,
        'imageUrl': imageUrl,
        'uploadedAt': uploadedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [imageId, imageUrl, uploadedAt];
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _asDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
