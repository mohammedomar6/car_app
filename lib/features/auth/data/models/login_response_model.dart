// To parse this JSON data, do
//
//     final loginResponseModel = loginResponseModelFromJson(jsonString);

import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) => LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) => json.encode(data.toJson());

class LoginResponseModel {
  final String token;
  final String message;

  LoginResponseModel({
    required this.token,
    required this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
    token: json["token"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "message": message,
  };
}
