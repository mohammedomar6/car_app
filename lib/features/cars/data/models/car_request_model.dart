import 'dart:io';

class CarRequestModel {
  final int brandId;
  final String model;
  final int year;
  final String color;
  final double price;
  final String fuelType;
  final String gearType;
  final int mileage;
  final String description;
  final double? rentPricePerDay;
  final String status;
  final List<String> imageUrls;
  final List<File> images;
  final int cylinders;
  final String interiorColor;
  final int keysCount;
  final String driveType;
  final String region;
  final int horsepower;
  final int topSpeed;

  const CarRequestModel({
    required this.brandId,
    required this.model,
    required this.year,
    required this.color,
    required this.price,
    required this.fuelType,
    required this.gearType,
    required this.mileage,
    required this.description,
    this.rentPricePerDay,
    required this.status,
    this.imageUrls = const [],
    this.images = const [],
    required this.cylinders,
    required this.interiorColor,
    required this.keysCount,
    required this.driveType,
    required this.region,
    required this.horsepower,
    required this.topSpeed,
  });

  Map<String, String> toMultipartFields() {
    return {
      'BrandId': brandId.toString(),
      'Model': model,
      'Year': year.toString(),
      'Color': color,
      'Price': price.toString(),
      'FuelType': fuelType,
      'GearType': gearType,
      'Mileage': mileage.toString(),
      'Description': description,
      if (rentPricePerDay != null)
        'RentPricePerDay': rentPricePerDay.toString(),
      'Status': status,
      'Cylinders': cylinders.toString(),
      'InteriorColor': interiorColor,
      'KeysCount': keysCount.toString(),
      'DriveType': driveType,
      'Region': region,
      'Horsepower': horsepower.toString(),
      'TopSpeed': topSpeed.toString(),
    };
  }
}
