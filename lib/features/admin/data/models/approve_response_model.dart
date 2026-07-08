// To parse this JSON data, do
//
//     final approveResponseModel = approveResponseModelFromJson(jsonString);

import 'dart:convert';

ApproveResponseModel approveResponseModelFromJson(String str) => ApproveResponseModel.fromJson(json.decode(str));

String approveResponseModelToJson(ApproveResponseModel data) => json.encode(data.toJson());

class ApproveResponseModel {
  final String? message;
  final String? currentStatus;

  ApproveResponseModel({
    this.message,
    this.currentStatus,
  });

  factory ApproveResponseModel.fromJson(Map<String, dynamic> json) => ApproveResponseModel(
    message: json["message"],
    currentStatus: json["currentStatus"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "currentStatus": currentStatus,
  };
}
