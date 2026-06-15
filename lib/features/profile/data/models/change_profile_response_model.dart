// To parse this JSON data, do
//
//     final changeProfileResponseModel = changeProfileResponseModelFromJson(jsonString);

import 'dart:convert';

ChangeProfileResponseModel changeProfileResponseModelFromJson(String str) =>
    ChangeProfileResponseModel.fromJson(json.decode(str));

String changeProfileResponseModelToJson(ChangeProfileResponseModel data) =>
    json.encode(data.toJson());

class ChangeProfileResponseModel {
  final String message;

  ChangeProfileResponseModel({required this.message});

  factory ChangeProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      ChangeProfileResponseModel(message: json["message"]);

  Map<String, dynamic> toJson() => {"message": message};
}
