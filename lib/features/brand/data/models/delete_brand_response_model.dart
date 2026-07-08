// To parse this JSON data, do
//
//     final deleteBrandResponseModel = deleteBrandResponseModelFromJson(jsonString);

import 'dart:convert';

DeleteBrandResponseModel deleteBrandResponseModelFromJson(String str) => DeleteBrandResponseModel.fromJson(json.decode(str));

String deleteBrandResponseModelToJson(DeleteBrandResponseModel data) => json.encode(data.toJson());

class DeleteBrandResponseModel {
  final String? message;

  DeleteBrandResponseModel({
    this.message,
  });

  factory DeleteBrandResponseModel.fromJson(Map<String, dynamic> json) => DeleteBrandResponseModel(
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
  };
}
