import 'dart:convert';

import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/brand/data/models/add_brand_model.dart';
import 'package:car_app/features/brand/data/models/brand_model.dart';
import 'package:car_app/features/brand/data/models/brand_request_model.dart';
import 'package:car_app/features/brand/data/models/delete_brand_response_model.dart';
import 'package:http/http.dart' as http;

class RemoteDataSourceBrand {
  Future<List<BrandModel>> getBrands() async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}Brands/All-Brands'),
      headers: AppStrings.headerApi,
    );
    if (response.statusCode == 200) {
      final List<dynamic> mapDate = jsonDecode(response.body);
      return mapDate.map((e) {
        return BrandModel.fromJson(e);
      }).toList();
    } else {
      throw Exception(jsonDecode(response.body));
    }
  }


  Future<AddBrandModel> addBrand(BrandRequestModel request) async {
    print(request.imageFile);
    var multipartRequest = http.MultipartRequest(
      "POST",
      Uri.parse("${AppStrings.baseUrl}Brands"),
    );

    // Headers
    multipartRequest.headers.addAll(await AppStrings.getHeaderApi());

    // البيانات النصية
    multipartRequest.fields["BrandName"] = request.brandName!;


    // الصورة
    if (request.imageFile != null && request.imageFile.path.isNotEmpty) {
      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          "ImageFile", // يجب أن يكون نفس الاسم الموجود في الـ API
          request.imageFile.path,
        ),
      );
    }

    // إرسال الطلب
    final streamedResponse = await multipartRequest.send();

    // تحويل Stream إلى Response
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> mapData = jsonDecode(response.body);
      return AddBrandModel.fromJson(mapData);
    } else {
      throw Exception(response.body);
    }
  }

  Future<DeleteBrandResponseModel> deleteBrand(int id) async {
    final response = await http.delete(
      Uri.parse("${AppStrings.baseUrl}Brands/$id"),
      headers: AppStrings.headerApi,
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> mapDate = jsonDecode(response.body);
      return DeleteBrandResponseModel.fromJson(mapDate);
    } else {
      throw Exception(jsonDecode(response.body));
    }
  }
}
