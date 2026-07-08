// To parse this JSON data, do
//
//     final brandModel = brandModelFromJson(jsonString);

import 'dart:convert';
import 'dart:io';

List<BrandModel> brandModelFromJson(String str) => List<BrandModel>.from(json.decode(str).map((x) => BrandModel.fromJson(x)));

String brandModelToJson(List<BrandModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BrandModel {
  final int? brandId;
  final String? name;
  final String? brandLogoUrl;
  final DateTime? createdAt;

  BrandModel({
    this.brandId,
    this.name,
    this.brandLogoUrl,
    this.createdAt,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
    brandId: json["brandId"],
    name: json["name"],
    brandLogoUrl: json["brandLogoUrl"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );
  Map<String, dynamic> toJson() => {
    "brandId": brandId,
    "name": name,
    "brandLogoUrl": brandLogoUrl,
    "createdAt": createdAt?.toIso8601String(),
  };
}
