// To parse this JSON data, do
//
//     final brandRequestModel = brandRequestModelFromJson(jsonString);

import 'dart:convert';
import 'dart:io';

EditRequestModel brandRequestModelFromJson(String str) => EditRequestModel.fromJson(json.decode(str));

String brandRequestModelToJson(EditRequestModel data) => json.encode(data.toJson());

class EditRequestModel {
  final String? brandName;
  final File? imageFile;

  EditRequestModel({
    this.brandName,
    required  this.imageFile,
  });

  factory EditRequestModel.fromJson(Map<String, dynamic> json) => EditRequestModel(
    brandName: json["BrandName"],
    imageFile: json["ImageFile"],
  );

  Map<String, dynamic> toJson() => {
    "BrandName": brandName,
    "ImageFile": imageFile,
  };
}
