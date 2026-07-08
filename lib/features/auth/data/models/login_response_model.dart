// To parse this JSON data, do
//
//     final loginResponseModel = loginResponseModelFromJson(jsonString);

import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) => LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) => json.encode(data.toJson());

class LoginResponseModel {
  final String token;
  final String message;
  final String role;

  LoginResponseModel({
    required this.token,
    required this.message,
    required this.role,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
    token: json["token"],
    message: json["message"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "message": message,
    "role": role,
  };
}
