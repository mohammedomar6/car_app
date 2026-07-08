// To parse this JSON data, do
//
//     final addBrandModel = addBrandModelFromJson(jsonString);

import 'dart:convert';

import 'brand_model.dart';

AddBrandModel addBrandModelFromJson(String str) => AddBrandModel.fromJson(json.decode(str));

String addBrandModelToJson(AddBrandModel data) => json.encode(data.toJson());

class AddBrandModel {
  final String? message;
  final BrandModel? brandModel;

  AddBrandModel({
    this.message,
    this.brandModel,
  });

  factory AddBrandModel.fromJson(Map<String, dynamic> json) => AddBrandModel(
    message: json["message"],
    brandModel: json["brand_model"] == null ? null : BrandModel.fromJson(json["brand_model"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "brand_model": brandModel?.toJson(),
  };
}