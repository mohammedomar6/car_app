import 'dart:convert';

import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/cars/data/models/car_response_model.dart';
import 'package:http/http.dart' as http;

class RemoteDataSourceCar {

  Future<List<CarResponseModel>> getCars() async {
    final response = await http.get(
        Uri.parse('${AppStrings.baseUrl}Cars'), headers: AppStrings.headerApi);
    if (response.statusCode == 200) {
      List<dynamic> mapData = jsonDecode(response.body);
      return mapData.map((e) => CarResponseModel.fromJson(e),).toList();
    }
    else {
      throw Exception(jsonDecode(response.body));
    }
  }

  Future<List<CarResponseModel>> getPendingCars() async {
    final response = await http.get(
        Uri.parse('${AppStrings.baseUrl}Cars/pending-cars'),
        headers: AppStrings.headerApi);
    if (response.statusCode == 200) {
      List<dynamic> mapData = jsonDecode(response.body);
      return mapData.map((e) => CarResponseModel.fromJson(e),).toList();
    }
    else {
      throw Exception(jsonDecode(response.body));
    }
  }

  Future<List<CarResponseModel>> getMyCars() async{
   final response = await http.get(Uri.parse('${AppStrings.baseUrl}Cars/my-cars'),
        headers:await AppStrings.getHeaderApi());
   print(response.statusCode);
   if(response.statusCode==200){
       List<dynamic> data = jsonDecode(response.body);
        return data.map((e) {
          return CarResponseModel.fromJson(e);
        },).toList();
   }
   else {
     throw Exception(response.body);
   }
  }
}