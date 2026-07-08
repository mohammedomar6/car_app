import 'dart:convert';

import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/core/utils/massage_model.dart';
import 'package:car_app/features/admin/data/models/approve_request_model.dart';
import 'package:car_app/features/admin/data/models/approve_response_model.dart';
import 'package:http/http.dart' as http;

class RemoteDataSourceAdmin {
  Future<ApproveResponseModel> approveCar(ApproveRequestModel request) async {
    final response = await http.patch(
      Uri.parse('${AppStrings.baseUrl}Admin/approve/'),
      headers: AppStrings.headerApi,
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      final mapData = jsonDecode(response.body);
      return ApproveResponseModel.fromJson(mapData);
    } else {
      throw Exception(jsonDecode(response.body));
    }
  }

  Future<MassageModel> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('${AppStrings.baseUrl}Admin/delete-user/$id'),
    );
    if (response.statusCode == 200) {
            Map<String,dynamic> map = jsonDecode(response.body);
      return MassageModel.fromJson(map);
    } else {
      throw Exception(jsonDecode(response.body));
    }
  }
}
