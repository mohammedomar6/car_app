import 'dart:convert';

import 'package:car_app/features/auth/data/models/login_request_model.dart';
import 'package:car_app/features/auth/data/models/login_response_model.dart';
import 'package:car_app/features/auth/data/models/register_request_model.dart';
import 'package:car_app/features/auth/data/models/register_response_model.dart';
import 'package:http/http.dart' as http;
class RemoteDataSourceAuth {
   Future<RegisterResponseModel> registerUser(RegisterRequestModel request)async  {
     print(request.email);
  final response =await http.post(Uri.parse("http://192.168.100.211:5222/api/Auth/register"),body:jsonEncode(request.toJson() ),
    headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },);
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
 final response=   await http.post(Uri.parse("http://192.168.100.211:5222/api/Auth/login"),body:jsonEncode(request.toJson()) ,headers: {
   'Content-Type': 'application/json',
   'Accept': 'application/json',
 },);
     if(response.statusCode==200){
     Map<String,dynamic>map=  jsonDecode(response.body);
     return LoginResponseModel.fromJson(map);
     }else{
       throw Exception(jsonDecode(response.body).toString());
     }
}


}
