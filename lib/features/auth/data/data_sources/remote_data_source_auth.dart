import 'dart:convert';

import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/core/utils/secure_storage.dart';
import 'package:car_app/features/auth/data/models/login_request_model.dart';
import 'package:car_app/features/auth/data/models/login_response_model.dart';
import 'package:car_app/features/auth/data/models/register_request_model.dart';
import 'package:car_app/features/auth/data/models/register_response_model.dart';
import 'package:http/http.dart' as http;
class RemoteDataSourceAuth {
   Future<RegisterResponseModel> registerUser(RegisterRequestModel request)async  {
     print(request.email);
  final response =await http.post(Uri.parse("${AppStrings.baseUrl}Auth/register"),body:jsonEncode(request.toJson() ),
    headers: AppStrings.headerApi);
    if(response.statusCode==200){
      print(response.statusCode);
      Map<String ,dynamic> map = jsonDecode(response.body);

      return  RegisterResponseModel.fromJson(map);
    }
    else {
      throw Exception(jsonDecode(response.body));
    }
}
   Future<LoginResponseModel> loginUser(LoginRequestModel request)async {
 final response=   await http.post(Uri.parse("${AppStrings.baseUrl}Auth/login"),body:jsonEncode(request.toJson()) ,
   headers: AppStrings.headerApi,);
     if(response.statusCode==200){
     Map<String,dynamic>map=  jsonDecode(response.body);
     LoginResponseModel responseModel = LoginResponseModel.fromJson(map);
   await  SecureStorageService.saveToken(responseModel.token);
   await  SecureStorageService.saveRole(responseModel.role);
     return responseModel;
     }else{
       throw Exception(jsonDecode(response.body).toString());
     }
}


}
