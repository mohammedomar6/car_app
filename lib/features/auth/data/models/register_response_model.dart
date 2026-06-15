// To parse this JSON data, do
//
//     final registerResponseModel = registerResponseModelFromJson(jsonString);

import 'dart:convert';

RegisterResponseModel registerResponseModelFromJson(String str) => RegisterResponseModel.fromJson(json.decode(str));

String registerResponseModelToJson(RegisterResponseModel data) => json.encode(data.toJson());

class RegisterResponseModel {
  final String message;
  final int userId;

  RegisterResponseModel({
    required this.message,
    required this.userId,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) => RegisterResponseModel(
    message: json["message"],
    userId: json["userId"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "userId": userId,
  };
}
