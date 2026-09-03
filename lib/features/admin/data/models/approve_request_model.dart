// To parse this JSON data, do
//
//     final approveRequestModel = approveRequestModelFromJson(jsonString);

import 'dart:convert';

ApproveRequestModel approveRequestModelFromJson(String str) => ApproveRequestModel.fromJson(json.decode(str));

String approveRequestModelToJson(ApproveRequestModel data) => json.encode(data.toJson());

class ApproveRequestModel {
  final int id;

  ApproveRequestModel({
    required this.id,
  });

  factory ApproveRequestModel.fromJson(Map<String, dynamic> json) => ApproveRequestModel(
    id: json["id"] is num
        ? (json["id"] as num).toInt()
        : int.tryParse(json["id"]?.toString() ?? '') ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
  };
}
