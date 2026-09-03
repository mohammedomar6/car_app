import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constant/app_strings.dart';
import '../../../cars/data/models/car_response_model.dart';

abstract class FavoriteRemoteDataSource {
  Future<List<CarResponseModel>> getMyFavorites();

  Future<String> toggleFavorite(int carId);
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  @override
  Future<List<CarResponseModel>> getMyFavorites() async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}Favorites/my-favorites'),
      headers: await AppStrings.getHeaderApi(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = response.body.trim().isEmpty ? <dynamic>[] : jsonDecode(response.body);
      final data = decoded is Map<String, dynamic>
          ? decoded['favorites'] ?? decoded['cars'] ?? decoded['data'] ?? []
          : decoded;

      if (data is List) {
        return data
            .map(
              (e) => CarResponseModel.fromJson(
            e as Map<String, dynamic>,
          ),
        )
            .toList();
      }

      return [];
    }

    throw Exception(_errorMessage(response));
  }

  @override
  Future<String> toggleFavorite(int carId) async {
    final response = await http.post(
      Uri.parse('${AppStrings.baseUrl}Favorites/toggle/$carId'),
      headers: await AppStrings.getHeaderApi(),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) return 'Favorites updated';
      try {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data['message']?.toString() ?? 'Favorites updated';
        }
        if (data is String) return data;
      } catch (_) {
        return response.body;
      }
      return 'Favorites updated';
    }

    throw Exception(_errorMessage(response));
  }

  String _errorMessage(http.Response response) {
    if (response.body.trim().isEmpty) {
      return 'Request failed (${response.statusCode})';
    }

    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return (data['message'] ?? data['title'] ?? data['error'] ?? response.body)
            .toString();
      }
    } catch (_) {
      // Plain-text API error.
    }
    return response.body;
  }
}
