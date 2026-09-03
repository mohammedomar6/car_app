import 'dart:convert';

import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/cars/data/models/car_operation_response_model.dart';
import 'package:car_app/features/cars/data/models/car_request_model.dart';
import 'package:car_app/features/cars/data/models/car_response_model.dart';
import 'package:car_app/features/cars/data/models/car_search_filters.dart';
import 'package:car_app/features/cars/data/models/car_status_filters.dart';
import 'package:http/http.dart' as http;

class RemoteDataSourceCar {
  Future<CarResponseModel> getCarById(int carId) async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}Cars/$carId'),
      headers: await AppStrings.getHeaderApi(),
    );

    if (!_isSuccess(response.statusCode)) {
      throw Exception(_errorMessage(response));
    }
    if (response.body.trim().isEmpty) {
      throw const FormatException('The car response is empty.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final item = decoded['car'] ?? decoded['data'] ?? decoded;
      if (item is Map) {
        return CarResponseModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }
    }
    throw const FormatException('Invalid car response.');
  }

  Future<List<CarResponseModel>> getCars() async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}Cars'),
      headers: await AppStrings.getHeaderApi(),
    );

    if (_isSuccess(response.statusCode)) {
      return _decodeCars(response.body);
    }
    throw Exception(_errorMessage(response));
  }

  Future<List<CarResponseModel>> getMyCars({
    CarStatusFilters filters = const CarStatusFilters(),
  }) async {
    final query = filters.toQueryParameters(includeOwnerId: false);
    final uri = Uri.parse('${AppStrings.baseUrl}Cars/my-cars').replace(
      queryParameters: query.isEmpty ? null : query,
    );
    final response = await http.get(
      uri,
      headers: await AppStrings.getHeaderApi(),
    );

    if (_isSuccess(response.statusCode)) {
      return _decodeCars(response.body);
    }
    throw Exception(_errorMessage(response));
  }

  Future<CarOperationResponseModel> addCar(CarRequestModel request) async {
    final multipartRequest = await _buildMultipartRequest(
      method: 'POST',
      uri: Uri.parse('${AppStrings.baseUrl}Cars/add'),
      request: request,
    );
    final response = await http.Response.fromStream(
      await multipartRequest.send(),
    );

    if (_isSuccess(response.statusCode)) {
      return _decodeOperationResponse(
        response,
        fallbackMessage: 'Car added successfully',
      );
    }
    throw Exception(_errorMessage(response));
  }

  Future<CarOperationResponseModel> editCar(
    int carId,
    CarRequestModel request,
  ) async {
    final multipartRequest = await _buildMultipartRequest(
      method: 'PUT',
      uri: Uri.parse('${AppStrings.baseUrl}Cars/$carId'),
      request: request,
    );
    final response = await http.Response.fromStream(
      await multipartRequest.send(),
    );

    if (_isSuccess(response.statusCode)) {
      return _decodeOperationResponse(
        response,
        fallbackMessage: 'Car updated successfully',
      );
    }
    throw Exception(_errorMessage(response));
  }

  Future<CarOperationResponseModel> deleteCar(int carId) async {
    final response = await http.delete(
      Uri.parse('${AppStrings.baseUrl}Cars/$carId'),
      headers: await AppStrings.getHeaderApi(),
    );

    if (_isSuccess(response.statusCode)) {
      return _decodeOperationResponse(
        response,
        fallbackMessage: 'Car deleted successfully',
      );
    }
    throw Exception(_errorMessage(response));
  }

  Future<List<CarResponseModel>> searchCars(
    CarSearchFilters filters,
  ) async {
    final uri = Uri.parse('${AppStrings.baseUrl}Cars/search').replace(
      queryParameters: filters.toQueryParameters(),
    );
    final response = await http.get(
      uri,
      headers: await AppStrings.getHeaderApi(),
    );

    if (_isSuccess(response.statusCode)) {
      return _decodeCars(response.body);
    }
    throw Exception(_errorMessage(response));
  }

  Future<http.MultipartRequest> _buildMultipartRequest({
    required String method,
    required Uri uri,
    required CarRequestModel request,
  }) async {
    final multipartRequest = http.MultipartRequest(method, uri);
    final headers = await AppStrings.getHeaderApi();

    // MultipartRequest must generate the content-type boundary itself.
    headers.removeWhere(
      (key, value) => key.toLowerCase() == 'content-type',
    );
    multipartRequest.headers.addAll(headers);
    multipartRequest.fields.addAll(request.toMultipartFields());

    for (var index = 0; index < request.imageUrls.length; index++) {
      multipartRequest.fields['ImageUrls[$index]'] = request.imageUrls[index];
    }
    for (final image in request.images) {
      multipartRequest.files.add(
        await http.MultipartFile.fromPath('Images', image.path),
      );
    }
    return multipartRequest;
  }

  List<CarResponseModel> _decodeCars(String body) {
    if (body.trim().isEmpty) return [];

    final decoded = jsonDecode(body);
    dynamic items = decoded;
    if (decoded is Map<String, dynamic>) {
      items = decoded['cars'] ?? decoded['data'] ?? decoded['items'] ?? [];
    }
    if (items is! List) return [];

    return items
        .whereType<Map>()
        .map(
          (item) => CarResponseModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  CarOperationResponseModel _decodeOperationResponse(
    http.Response response, {
    required String fallbackMessage,
  }) {
    if (response.body.trim().isEmpty) {
      return CarOperationResponseModel(message: fallbackMessage);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return CarOperationResponseModel.fromJson(decoded);
    }
    return CarOperationResponseModel(message: fallbackMessage);
  }

  String _errorMessage(http.Response response) {
    if (response.body.trim().isEmpty) {
      return 'Request failed (${response.statusCode})';
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['title'] ?? decoded['error'];
        if (message != null) return message.toString();

        final errors = decoded['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
          return first.toString();
        }
      }
    } catch (_) {
      // The API returned plain text rather than JSON.
    }
    return response.body;
  }

  bool _isSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;
}
