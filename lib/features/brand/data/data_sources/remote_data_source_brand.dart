import 'dart:convert';

import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/brand/data/models/add_brand_model.dart';
import 'package:car_app/features/brand/data/models/brand_model.dart';
import 'package:car_app/features/brand/data/models/brand_request_model.dart';
import 'package:car_app/features/brand/data/models/delete_brand_response_model.dart';
import 'package:http/http.dart' as http;

class RemoteDataSourceBrand {
  // ============================================================
  // GET ALL BRANDS
  // ============================================================

  Future<List<BrandModel>> getBrands() async {
    final response = await http.get(
      Uri.parse(
        '${AppStrings.baseUrl}Brands/All-Brands',
      ),
      headers: AppStrings.headerApi,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((e) => BrandModel.fromJson(e))
          .toList();
    }

    throw Exception(response.body);
  }

  // ============================================================
  // ADD BRAND
  // ============================================================

  Future<AddBrandModel> addBrand(
      BrandRequestModel request,
      ) async {
    final multipartRequest = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${AppStrings.baseUrl}Brands',
      ),
    );

    multipartRequest.headers.addAll(
      await AppStrings.getHeaderApi(),
    );

    multipartRequest.fields['BrandName'] =
        request.brandName;

    if (request.imageFile != null) {
      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          'ImageFile',
          request.imageFile!.path,
        ),
      );
    }

    final streamedResponse =
    await multipartRequest.send();

    final response =
    await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode == 200) {
      return AddBrandModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(response.body);
  }

  // ============================================================
  // EDIT BRAND
  // ============================================================

  Future<AddBrandModel> editBrand(
      int brandId,
      BrandRequestModel request,
      ) async {
    final multipartRequest = http.MultipartRequest(
      'PUT',
      Uri.parse(
        '${AppStrings.baseUrl}Brands/$brandId',
      ),
    );

    multipartRequest.headers.addAll(
      await AppStrings.getHeaderApi(),
    );

    // Brand name is always required
    multipartRequest.fields['BrandName'] =
        request.brandName;

    // Image is OPTIONAL during edit
    if (request.imageFile != null) {
      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          'ImageFile',
          request.imageFile!.path,
        ),
      );
    }

    final streamedResponse =
    await multipartRequest.send();

    final response =
    await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode == 200) {
      return AddBrandModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(response.body);
  }

  // ============================================================
  // DELETE BRAND
  // ============================================================

  Future<DeleteBrandResponseModel> deleteBrand(
      int brandId,
      ) async {
    final response = await http.delete(
      Uri.parse(
        '${AppStrings.baseUrl}Brands/$brandId',
      ),
      headers: await AppStrings.getHeaderApi(),
    );

    if (response.statusCode == 200) {
      return DeleteBrandResponseModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(response.body);
  }
}