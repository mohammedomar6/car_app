//To parse this JSON data, do
//
//final carResponseModel = carResponseModelFromJson(jsonString);

import 'dart:convert';

List<CarResponseModel> carResponseModelFromJson(String str) => List<CarResponseModel>.from(json.decode(str).map((x) => CarResponseModel.fromJson(x)));

String carResponseModelToJson(List<CarResponseModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CarResponseModel {
  int carId;
  int userId;
  String brand;
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
  dynamic approvedBy;
  dynamic approvalNotes;
  dynamic approvalDate;
  List<String> imageUrls;

  CarResponseModel({
    required this.carId,
    required this.userId,
    required this.brand,
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
    required this.approvedBy,
    required this.approvalNotes,
    required this.approvalDate,
    required this.imageUrls,
  });

  factory CarResponseModel.fromJson(Map<String, dynamic> json) => CarResponseModel(
    carId: json["carId"],
    userId: json["userId"],
    brand: json["brand"],
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
    approvedBy: json["approvedBy"],
    approvalNotes: json["approvalNotes"],
    approvalDate: json["approvalDate"],
    imageUrls: List<String>.from(json["imageUrls"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "carId": carId,
    "userId": userId,
    "brand": brand,
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
    "approvedBy": approvedBy,
    "approvalNotes": approvalNotes,
    "approvalDate": approvalDate,
    "imageUrls": List<dynamic>.from(imageUrls.map((x) => x)),
  };
}