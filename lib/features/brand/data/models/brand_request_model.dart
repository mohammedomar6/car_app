// To parse this JSON data, do
//
//     final brandRequestModel = brandRequestModelFromJson(jsonString);

import 'dart:convert';
import 'dart:io';

BrandRequestModel brandRequestModelFromJson(String str) => BrandRequestModel.fromJson(json.decode(str));

String brandRequestModelToJson(BrandRequestModel data) => json.encode(data.toJson());

class BrandRequestModel {
  final String? brandName;
  final File imageFile;

  BrandRequestModel({
    this.brandName,
  required  this.imageFile,
  });

  factory BrandRequestModel.fromJson(Map<String, dynamic> json) => BrandRequestModel(
    brandName: json["BrandName"],
    imageFile: json["ImageFile"],
  );

  Map<String, dynamic> toJson() => {
    "BrandName": brandName,
    "ImageFile": imageFile,
  };
}
