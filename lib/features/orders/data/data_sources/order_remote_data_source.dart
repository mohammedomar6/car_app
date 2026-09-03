import 'dart:convert';

import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/orders/data/models/order_availability.dart';
import 'package:car_app/features/orders/data/models/order_model.dart';
import 'package:car_app/features/orders/data/models/order_operation_response.dart';
import 'package:car_app/features/orders/data/models/order_requests.dart';
import 'package:http/http.dart' as http;

class OrderRemoteDataSource {
  Future<OrderOperationResponse> createRentOrder(
    RentOrderRequest request,
  ) {
    return _createMultipartOrder(
      endpoint: 'Orders/rent',
      request: request,
      fallbackMessage: 'Rent order created successfully.',
    );
  }

  Future<OrderOperationResponse> createBuyOrder(BuyOrderRequest request) {
    return _createMultipartOrder(
      endpoint: 'Orders/buy',
      request: request,
      fallbackMessage: 'Buy order created successfully.',
    );
  }

  Future<OrderOperationResponse> createInstallmentOrder(
    InstallmentOrderRequest request,
  ) {
    return _createMultipartOrder(
      endpoint: 'Orders/installment',
      request: request,
      fallbackMessage: 'Installment order created successfully.',
    );
  }

  Future<List<OrderModel>> getMyOrders() async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}Orders/my-orders'),
      headers: await AppStrings.getHeaderApi(),
    );

    if (_isSuccess(response.statusCode)) return _decodeOrders(response.body);
    throw Exception(_errorMessage(response));
  }

  Future<List<OrderModel>> getAdminOrders({
    String? status,
    String? type,
  }) async {
    final query = <String, String>{
      if (status != null && status.isNotEmpty) 'status': status,
      if (type != null && type.isNotEmpty) 'type': type,
    };
    final uri = Uri.parse('${AppStrings.baseUrl}Orders/admin/all').replace(
      queryParameters: query.isEmpty ? null : query,
    );
    final response = await http.get(
      uri,
      headers: await AppStrings.getHeaderApi(),
    );

    if (_isSuccess(response.statusCode)) return _decodeOrders(response.body);
    throw Exception(_errorMessage(response));
  }

  Future<OrderModel> getOrderById(int orderId) async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}Orders/$orderId'),
      headers: await AppStrings.getHeaderApi(),
    );

    if (!_isSuccess(response.statusCode)) {
      throw Exception(_errorMessage(response));
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      return OrderModel.fromJson(
        data is Map<String, dynamic> ? data : decoded,
      );
    }
    throw const FormatException('Invalid order response.');
  }

  Future<OrderOperationResponse> reviewOrder(
    ReviewOrderRequest request,
  ) async {
    final uri = Uri.parse('${AppStrings.baseUrl}Orders/review');
    final headers = await AppStrings.getHeaderApi();
    final body = jsonEncode(request.toJson());
    final response = await _sendActionWithFallback(
      uri: uri,
      headers: headers,
      body: body,
    );

    if (_isSuccess(response.statusCode)) {
      return _decodeOperation(
        response,
        fallbackMessage: 'Order status updated successfully.',
      );
    }
    throw Exception(_errorMessage(response));
  }

  Future<OrderOperationResponse> cancelOrder(int orderId) async {
    final uri = Uri.parse('${AppStrings.baseUrl}Orders/$orderId/cancel');
    final headers = await AppStrings.getHeaderApi();
    final response = await _sendActionWithFallback(uri: uri, headers: headers);

    if (_isSuccess(response.statusCode)) {
      return _decodeOperation(
        response,
        fallbackMessage: 'Order has been canceled successfully.',
      );
    }
    throw Exception(_errorMessage(response));
  }

  Future<OrderAvailability> checkAvailability({
    required int carId,
    required String orderType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = <String, String>{
      'orderType': orderType,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    };
    final uri = Uri.parse(
      '${AppStrings.baseUrl}Orders/$carId/check-availability',
    ).replace(queryParameters: query);
    final response = await http.get(
      uri,
      headers: await AppStrings.getHeaderApi(),
    );

    if (!_isSuccess(response.statusCode)) {
      throw Exception(_errorMessage(response));
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return OrderAvailability.fromJson(decoded);
    }
    throw const FormatException('Invalid availability response.');
  }

  Future<OrderOperationResponse> _createMultipartOrder({
    required String endpoint,
    required OrderRequest request,
    required String fallbackMessage,
  }) async {
    final multipart = http.MultipartRequest(
      'POST',
      Uri.parse('${AppStrings.baseUrl}$endpoint'),
    );
    final headers = await AppStrings.getHeaderApi();
    headers.removeWhere(
      (key, value) => key.toLowerCase() == 'content-type',
    );
    multipart.headers.addAll(headers);
    multipart.fields.addAll(request.toMultipartFields());

    for (final document in request.documents) {
      multipart.files.add(
        await http.MultipartFile.fromPath('Documents', document.path),
      );
    }

    final response = await http.Response.fromStream(await multipart.send());
    if (_isSuccess(response.statusCode)) {
      return _decodeOperation(response, fallbackMessage: fallbackMessage);
    }
    throw Exception(_errorMessage(response));
  }

  Future<http.Response> _sendActionWithFallback({
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  }) async {
    var response = await http.patch(uri, headers: headers, body: body);
    if (response.statusCode != 404 && response.statusCode != 405) {
      return response;
    }

    response = await http.put(uri, headers: headers, body: body);
    if (response.statusCode != 404 && response.statusCode != 405) {
      return response;
    }
    return http.post(uri, headers: headers, body: body);
  }

  List<OrderModel> _decodeOrders(String body) {
    if (body.trim().isEmpty) return [];
    final decoded = jsonDecode(body);
    dynamic items = decoded;
    if (decoded is Map<String, dynamic>) {
      items = decoded['orders'] ?? decoded['data'] ?? decoded['items'] ?? [];
    }
    if (items is! List) return [];

    return items
        .whereType<Map>()
        .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  OrderOperationResponse _decodeOperation(
    http.Response response, {
    required String fallbackMessage,
  }) {
    if (response.body.trim().isEmpty) {
      return OrderOperationResponse(message: fallbackMessage);
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return OrderOperationResponse.fromJson(decoded);
      }
    } catch (_) {
      return OrderOperationResponse(message: response.body);
    }
    return OrderOperationResponse(message: fallbackMessage);
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
      // The API returned plain text.
    }
    return response.body;
  }

  bool _isSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;
}
