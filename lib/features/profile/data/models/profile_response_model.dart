// To parse this JSON data, do
//
//     final profileResponseModel = profileResponseModelFromJson(jsonString);

import 'dart:convert';

ProfileResponseModel profileResponseModelFromJson(String str) => ProfileResponseModel.fromJson(json.decode(str));

String profileResponseModelToJson(ProfileResponseModel data) => json.encode(data.toJson());

class ProfileResponseModel {
  final int? userId;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? address;
  final String? role;
  final DateTime? createdAt;

  ProfileResponseModel({
     this.userId,
     this.fullName,
     this.email,
     this.phone,
     this.address,
     this.role,
     this.createdAt,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) => ProfileResponseModel(
    userId: json["userId"],
    fullName: json["fullName"],
    email: json["email"],
    phone: json["phone"],
    address: json["address"],
    role: json["role"],
    createdAt: DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "fullName": fullName,
    "email": email,
    "phone": phone,
    "address": address,
    "role": role,
    "createdAt": createdAt!.toIso8601String(),
  };
}
