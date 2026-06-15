// To parse this JSON data, do
//
//     final changePasswordRequestModel = changePasswordRequestModelFromJson(jsonString);

import 'dart:convert';

ChangePasswordRequestModel changePasswordRequestModelFromJson(String str) => ChangePasswordRequestModel.fromJson(json.decode(str));

String changePasswordRequestModelToJson(ChangePasswordRequestModel data) => json.encode(data.toJson());

class ChangePasswordRequestModel {
  final String oldPassword;
  final String newPassword;

  ChangePasswordRequestModel({
    required this.oldPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequestModel.fromJson(Map<String, dynamic> json) => ChangePasswordRequestModel(
    oldPassword: json["oldPassword"],
    newPassword: json["newPassword"],
  );

  Map<String, dynamic> toJson() => {
    "oldPassword": oldPassword,
    "newPassword": newPassword,
  };
}
