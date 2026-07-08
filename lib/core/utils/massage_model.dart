// To parse this JSON data, do
//
//     final massageModel = massageModelFromJson(jsonString);

import 'dart:convert';

MassageModel massageModelFromJson(String str) => MassageModel.fromJson(json.decode(str));

String massageModelToJson(MassageModel data) => json.encode(data.toJson());

class MassageModel {
  final String? message;

  MassageModel({
    this.message,
  });

  factory MassageModel.fromJson(Map<String, dynamic> json) => MassageModel(
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
  };
}
