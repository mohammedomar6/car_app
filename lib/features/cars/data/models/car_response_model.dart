// To parse this JSON data, do
//
//     final carResponseModel = carResponseModelFromJson(jsonString);

import 'dart:convert';

List<CarResponseModel> carResponseModelFromJson(String str) => List<CarResponseModel>.from(json.decode(str).map((x) => CarResponseModel.fromJson(x)));

String carResponseModelToJson(List<CarResponseModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CarResponseModel {
  int carId;
  int userId;
  int brandId;
  String model;
  int year;
  dynamic color;
  double price;
  String fuelType;
  String gearType;
  int mileage;
  dynamic description;
  bool isApproved;
  dynamic rentPricePerDay;
  String status;
  DateTime createdAt;

  dynamic approvalNotes;
  dynamic approvalDate;
  List<String> imageUrls;
  int cylinders;
  String interiorColor;
  int keysCount;
  String driveType;
  String region;
  int horsepower;
  int topSpeed;

  CarResponseModel({
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
    required this.isApproved,
    required this.rentPricePerDay,
    required this.status,
    required this.createdAt,


    required this.approvalNotes,
    required this.approvalDate,
    required this.imageUrls,
    required this.cylinders,
    required this.interiorColor,
    required this.keysCount,
    required this.driveType,
    required this.region,
    required this.horsepower,
    required this.topSpeed,
  });

  factory CarResponseModel.fromJson(Map<String, dynamic> json) => CarResponseModel(
    carId: json["carId"],
    userId: json["userId"],
    brandId: json["brandId"],
    model: json["model"],
    year: json["year"],
    color: json["color"],
    price: json["price"],
    fuelType: json["fuelType"],
    gearType: json["gearType"],
    mileage: json["mileage"],
    description: json["description"],
    isApproved: json["isApproved"],
    rentPricePerDay: json["rentPricePerDay"],
    status: json["status"],
    createdAt: DateTime.parse(json["createdAt"]),

    approvalNotes: json["approvalNotes"],
    approvalDate: json["approvalDate"],
    imageUrls: List<String>.from(json["imageUrls"].map((x) => x)),
    cylinders: json["cylinders"],
    interiorColor: json["interiorColor"],
    keysCount: json["keysCount"],
    driveType: json["driveType"],
    region: json["region"],
    horsepower: json["horsepower"],
    topSpeed: json["topSpeed"],
  );

  Map<String, dynamic> toJson() => {
    "carId": carId,
    "userId": userId,
    "brandId": brandId,
    "model": model,
    "year": year,
    "color": color,
    "price": price,
    "fuelType": fuelType,
    "gearType": gearType,
    "mileage": mileage,
    "description": description,
    "isApproved": isApproved,
    "rentPricePerDay": rentPricePerDay,
    "status": status,
    "createdAt": createdAt.toIso8601String(),

    "approvalNotes": approvalNotes,
    "approvalDate": approvalDate,
    "imageUrls": List<dynamic>.from(imageUrls.map((x) => x)),
    "cylinders": cylinders,
    "interiorColor": interiorColor,
    "keysCount": keysCount,
    "driveType": driveType,
    "region": region,
    "horsepower": horsepower,
    "topSpeed": topSpeed,
  };
}