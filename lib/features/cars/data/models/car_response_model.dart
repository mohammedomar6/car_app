import 'dart:convert';

List<CarResponseModel> carResponseModelFromJson(String source) {
  final decoded = jsonDecode(source) as List<dynamic>;
  return decoded
      .map((item) => CarResponseModel.fromJson(item as Map<String, dynamic>))
      .toList();
}

String carResponseModelToJson(List<CarResponseModel> data) {
  return jsonEncode(data.map((car) => car.toJson()).toList());
}

class CarResponseModel {
  final int carId;
  final int userId;
  final int brandId;
  final String model;
  final int year;
  final String color;
  final double price;
  final String fuelType;
  final String gearType;
  final int mileage;
  final String description;
  final String approvalStatus;
  final double? rentPricePerDay;
  final String availabilityStatus;
  final DateTime createdAt;
  final String? approvalNotes;
  final DateTime? approvalDate;
  final int? approvedBy;
  final List<String> imageUrls;
  final int cylinders;
  final String interiorColor;
  final int keysCount;
  final String driveType;
  final String region;
  final int horsepower;
  final int topSpeed;
  final String? brandLogoUrl;

  const CarResponseModel({
    required this.carId,
    required this.userId,
    required this.brandId,
    required this.model,
    required this.year,
    required this.color,
    required this.price,
    required this.fuelType,
    required this.gearType,
    required this.mileage,
    required this.description,
    required this.approvalStatus,
    required this.rentPricePerDay,
    required this.availabilityStatus,
    required this.createdAt,
    required this.approvalNotes,
    required this.approvalDate,
    required this.approvedBy,
    required this.imageUrls,
    required this.cylinders,
    required this.interiorColor,
    required this.keysCount,
    required this.driveType,
    required this.region,
    required this.horsepower,
    required this.topSpeed,
    required this.brandLogoUrl,
  });

  factory CarResponseModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['imageUrls'];

    return CarResponseModel(
      carId: _asInt(json['carId']),
      userId: _asInt(json['userId']),
      brandId: _asInt(json['brandId']),
      model: json['model']?.toString() ?? '',
      year: _asInt(json['year']),
      color: json['color']?.toString() ?? '',
      price: _asDouble(json['price']),
      fuelType: json['fuelType']?.toString() ?? '',
      gearType: json['gearType']?.toString() ?? '',
      mileage: _asInt(json['mileage']),
      description: json['description']?.toString() ?? '',
      approvalStatus: _approvalStatus(json),
      rentPricePerDay: _asNullableDouble(json['rentPricePerDay']),
      availabilityStatus:
          (json['availabilityStatus'] ?? json['status'])?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      approvalNotes: json['approvalNotes']?.toString(),
      approvalDate: DateTime.tryParse(json['approvalDate']?.toString() ?? ''),
      approvedBy: _asNullableInt(json['approvedBy']),
      imageUrls: rawImages is List
          ? rawImages.where((item) => item != null).map((item) => item.toString()).toList()
          : const [],
      cylinders: _asInt(json['cylinders']),
      interiorColor: json['interiorColor']?.toString() ?? '',
      keysCount: _asInt(json['keysCount']),
      driveType: json['driveType']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      horsepower: _asInt(json['horsepower']),
      topSpeed: _asInt(json['topSpeed']),
      brandLogoUrl: json['brandLogoUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'carId': carId,
        'userId': userId,
        'brandId': brandId,
        'model': model,
        'year': year,
        'color': color,
        'price': price,
        'fuelType': fuelType,
        'gearType': gearType,
        'mileage': mileage,
        'description': description,
        'approvalStatus': approvalStatus,
        'rentPricePerDay': rentPricePerDay,
        'availabilityStatus': availabilityStatus,
        'createdAt': createdAt.toIso8601String(),
        'approvalNotes': approvalNotes,
        'approvalDate': approvalDate?.toIso8601String(),
        'approvedBy': approvedBy,
        'imageUrls': imageUrls,
        'cylinders': cylinders,
        'interiorColor': interiorColor,
        'keysCount': keysCount,
        'driveType': driveType,
        'region': region,
        'horsepower': horsepower,
        'topSpeed': topSpeed,
        'brandLogoUrl': brandLogoUrl,
      };

  /// Compatibility getters for widgets and older cached responses.
  bool get isApproved => approvalStatus.toLowerCase() == 'approved';

  String get status => availabilityStatus;

  static String _approvalStatus(Map<String, dynamic> json) {
    final value = json['approvalStatus']?.toString();
    if (value != null && value.trim().isNotEmpty) return value;
    if (json['isApproved'] == true) return 'Approved';
    if (json['isApproved'] == false) return 'Pending';
    return '';
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _asNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
