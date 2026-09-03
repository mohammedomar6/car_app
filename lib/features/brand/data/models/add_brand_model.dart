import 'brand_model.dart';

class AddBrandModel {
  final String? message;
  final BrandModel? brandModel;

  AddBrandModel({
    this.message,
    this.brandModel,
  });

  factory AddBrandModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AddBrandModel(
      message: json['message'],
      brandModel: json['brand_model'] == null
          ? null
          : BrandModel.fromJson(
        json['brand_model'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'brand_model': brandModel?.toJson(),
    };
  }
}