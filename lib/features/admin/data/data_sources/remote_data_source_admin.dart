import 'dart:convert';

import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/core/utils/massage_model.dart';
import 'package:car_app/features/admin/data/models/approve_request_model.dart';
import 'package:car_app/features/admin/data/models/approve_response_model.dart';
import 'package:car_app/features/admin/data/models/reject_car_request_model.dart';
import 'package:car_app/features/cars/data/models/car_response_model.dart';
import 'package:car_app/features/cars/data/models/car_status_filters.dart';
import 'package:car_app/features/profile/data/models/profile_response_model.dart';
import 'package:http/http.dart' as http;

class RemoteDataSourceAdmin {
  Future<ApproveResponseModel> approveCar(ApproveRequestModel request) async {
    final response = await http.patch(
      Uri.parse('${AppStrings.baseUrl}Admin/approve/${request.id}'),
      headers: await AppStrings.getHeaderApi(),
      body: jsonEncode(request.id.toString()),
    );
    return _decodeCarAction(
      response,
      fallbackMessage: 'Car approved successfully.',
      fallbackStatus: 'Approved',
    );
  }

  Future<ApproveResponseModel> rejectCar(
    RejectCarRequestModel request,
  ) async {
    final response = await http.patch(
      Uri.parse('${AppStrings.baseUrl}Admin/reject/${request.carId}'),
      headers: await AppStrings.getHeaderApi(),
      // The endpoint expects the notes as a raw JSON string.
      body: jsonEncode(request.adminNotes.trim()),
    );
    return _decodeCarAction(
      response,
      fallbackMessage: 'Car rejected successfully.',
      fallbackStatus: 'Rejected',
    );
  }

  Future<List<CarResponseModel>> getAdminCars({
    CarStatusFilters filters = const CarStatusFilters(),
  }) async {
    final query = filters.toQueryParameters();
    final uri = Uri.parse('${AppStrings.baseUrl}Admin/cars').replace(
      queryParameters: query.isEmpty ? null : query,
    );
    final response = await http.get(
      uri,
      headers: await AppStrings.getHeaderApi(),
    );

    if (!_isSuccess(response.statusCode)) {
      throw Exception(_errorMessage(response));
    }
    return _decodeCars(response.body);
  }

  Future<MassageModel> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('${AppStrings.baseUrl}Admin/delete-user/$id'),
      headers: await AppStrings.getHeaderApi(),
    );

    if (_isSuccess(response.statusCode)) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return MassageModel.fromJson(decoded);
    }
    throw Exception(_errorMessage(response));
  }

  Future<List<ProfileResponseModel>> getUsers() async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}Auth/all_users'),
      headers: await AppStrings.getHeaderApi(),
    );
    if (!_isSuccess(response.statusCode)) {
      throw Exception(_errorMessage(response));
    }

    if (response.body.trim().isEmpty) return [];

    final decoded = jsonDecode(response.body);
    dynamic items = decoded;
    if (decoded is Map<String, dynamic>) {
      items = decoded['users'] ?? decoded['data'] ?? decoded['items'] ?? [];
    }
    if (items is! List) return [];
    return items
        .whereType<Map>()
        .map(
          (item) => ProfileResponseModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  ApproveResponseModel _decodeCarAction(
    http.Response response, {
    required String fallbackMessage,
    required String fallbackStatus,
  }) {
    if (!_isSuccess(response.statusCode)) {
      throw Exception(_errorMessage(response));
    }
    if (response.body.trim().isEmpty) {
      return ApproveResponseModel(
        message: fallbackMessage,
        currentStatus: fallbackStatus,
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return ApproveResponseModel.fromJson(decoded);
    }
    return ApproveResponseModel(
      message: fallbackMessage,
      currentStatus: fallbackStatus,
    );
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

  String _errorMessage(http.Response response) {
    if (response.body.trim().isEmpty) {
      return 'Request failed (${response.statusCode}).';
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
      // The API returned a plain-text error.
    }
    return response.body;
  }

  bool _isSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;
}
