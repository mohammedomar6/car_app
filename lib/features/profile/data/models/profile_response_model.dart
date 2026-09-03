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


  ProfileResponseModel({
     this.userId,
     this.fullName,
     this.email,
     this.phone,
     this.address,
     this.role,

  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) => ProfileResponseModel(
    userId: _asNullableInt(json["userId"] ?? json["id"]),
    fullName: (json["fullName"] ?? json["name"] ?? json["userName"])?.toString(),
    email: json["email"]?.toString(),
    phone: (json["phone"] ?? json["phoneNumber"])?.toString(),
    address: (json["address"] ?? json["location"])?.toString(),
    role: (json["role"] ?? json["userRole"])?.toString(),

  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "fullName": fullName,
    "email": email,
    "phone": phone,
    "address": address,
    "role": role,

  };
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
