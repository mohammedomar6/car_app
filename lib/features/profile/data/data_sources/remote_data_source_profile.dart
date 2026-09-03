import 'dart:convert';

import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/core/utils/massage_model.dart';
import 'package:car_app/features/profile/data/models/change_password_request_model.dart';
import 'package:car_app/features/profile/data/models/change_profile_response_model.dart';
import 'package:car_app/features/profile/data/models/profile_response_model.dart';
import 'package:http/http.dart ' as http;

class RemoteDataSourceProfile {
  Future<ProfileResponseModel> getProfile() async {
    final response = await http.get(
      Uri.parse("${AppStrings.baseUrl}Auth/profile"),
      headers: await AppStrings.getHeaderApi(),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      return ProfileResponseModel.fromJson(map);
    } else {
      throw Exception(response.body);
    }
  }

  Future<MassageModel> deleteAccount() async {
    final response = await http.delete(
      Uri.parse('${AppStrings.baseUrl}Auth/delete-account'),
      headers: await AppStrings.getHeaderApi(),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return MassageModel.fromJson(data);
    } else {
      throw Exception(jsonDecode(response.body));
    }
  }

  Future<ChangeProfileResponseModel> changeProfile(
    ProfileResponseModel request,
  ) async {
    final response = await http.put(
      Uri.parse("${AppStrings.baseUrl}Auth/update-profile"),
      headers: await AppStrings.getHeaderApi(),

      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      return ChangeProfileResponseModel.fromJson(map);
    } else {
      throw Exception("error");
    }
  }

  Future<ChangeProfileResponseModel> changePassword(
    ChangePasswordRequestModel request,
  ) async {
    final response = await http.post(
      Uri.parse('${AppStrings.baseUrl}Auth/change-password'),
      headers: await AppStrings.getHeaderApi(),
      body: jsonEncode(request.toJson()),
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      return ChangeProfileResponseModel.fromJson(map);
    } else {
      throw Exception(jsonDecode(response.body));
    }
  }
}
