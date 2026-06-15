import 'dart:convert';

import 'package:car_app/features/profile/data/models/change_password_request_model.dart';
import 'package:car_app/features/profile/data/models/change_profile_response_model.dart';
import 'package:car_app/features/profile/data/models/profile_response_model.dart';
import 'package:http/http.dart 'as http;
class RemoteDataSourceProfile {
  Future<ProfileResponseModel> getProfile()async{
   final response=await http.get(Uri.parse('uri') );
   if(response.statusCode==200){
     Map<String,dynamic> map= jsonDecode( response.body);
     return ProfileResponseModel.fromJson(map);
   }
   else{
     throw Exception("error");
   }

  }
  Future<ChangeProfileResponseModel> changeProfile(ProfileResponseModel request) async{
   final response=await http.put(Uri.parse("uri"),body: jsonEncode(request.toJson()));
   if(response.statusCode==200){
    Map<String,dynamic> map= jsonDecode(response.body);
    return ChangeProfileResponseModel.fromJson(map);
   }
   else
     {throw Exception("error");
     }

  }
 Future<ChangeProfileResponseModel> changePassword(ChangePasswordRequestModel request) async{
    final response = await http.post(Uri.parse("uri"),body:jsonEncode(request.toJson()) );
    if(response.statusCode==200){
      Map<String,dynamic>map =jsonDecode(response.body);
      return ChangeProfileResponseModel.fromJson(map);
    }
    else{throw Exception("Error");}
 }
  }