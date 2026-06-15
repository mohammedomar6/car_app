import 'dart:convert';

import 'package:car_app/features/auth/data/models/login_request_model.dart';
import 'package:car_app/features/auth/data/models/login_response_model.dart';
import 'package:car_app/features/auth/data/models/register_request_model.dart';
import 'package:car_app/features/auth/data/models/register_response_model.dart';
import 'package:http/http.dart' as http;
class RemoteDataSourceAuth {
   Future<RegisterResponseModel> registerUser(RegisterRequestModel request)async  {
  final response =await http.post(Uri.parse("uri"),body:jsonEncode(request.toJson() ));
    if(response.statusCode==200){
      Map<String ,dynamic> map = jsonDecode(response.body);

      return  RegisterResponseModel.fromJson(map);
    }
    else {
      throw Exception("Error BackEnd");
    }
}
   Future<LoginResponseModel> loginUser(LoginRequestModel request)async {
 final response=   await http.post(Uri.parse("uri"),body:jsonEncode(request.toJson()) );
     if(response.statusCode==200){
     Map<String,dynamic>map=  jsonDecode(response.body);
     return LoginResponseModel.fromJson(map);
     }else{
       throw Exception("sdfghj");
     }
}


}
