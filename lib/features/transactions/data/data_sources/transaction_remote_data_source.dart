import 'dart:convert';

import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/transactions/data/models/transaction_model.dart';
import 'package:car_app/features/transactions/data/models/transaction_operation_response.dart';
import 'package:car_app/features/transactions/data/models/transaction_request.dart';
import 'package:http/http.dart' as http;

class TransactionRemoteDataSource {
  Future<TransactionOperationResponse> createTransaction(
    TransactionRequest request,
  ) async {
    final response = await _sendMultipart(
      method: 'POST',
      uri: Uri.parse('${AppStrings.baseUrl}Transactions'),
      request: request,
    );
    return _decodeOperation(
      response,
      fallbackMessage: 'Transaction created successfully.',
    );
  }

  Future<TransactionOperationResponse> updateTransaction(
    int transactionId,
    TransactionRequest request,
  ) async {
    final response = await _sendMultipart(
      method: 'PUT',
      uri: Uri.parse('${AppStrings.baseUrl}Transactions/$transactionId'),
      request: request,
    );
    return _decodeOperation(
      response,
      fallbackMessage: 'Transaction updated successfully.',
    );
  }

  Future<TransactionOperationResponse> deleteTransaction(
    int transactionId,
  ) async {
    final response = await http.delete(
      Uri.parse('${AppStrings.baseUrl}Transactions/$transactionId'),
      headers: await AppStrings.getHeaderApi(),
    );
    return _decodeOperation(
      response,
      fallbackMessage: 'Transaction deleted successfully.',
    );
  }

  Future<List<TransactionModel>> getTransactions() {
    return _getTransactionList(
      Uri.parse('${AppStrings.baseUrl}Transactions'),
    );
  }

  Future<List<TransactionModel>> getMyTransactions() {
    return _getTransactionList(
      Uri.parse('${AppStrings.baseUrl}Transactions/my-transactions'),
    );
  }

  Future<List<TransactionModel>> getTransactionsByUser(int userId) {
    return _getTransactionList(
      Uri.parse('${AppStrings.baseUrl}Transactions/user/$userId'),
    );
  }

  Future<List<TransactionModel>> getTransactionsByOrder(int orderId) {
    return _getTransactionList(
      Uri.parse('${AppStrings.baseUrl}Transactions/order/$orderId'),
    );
  }

  Future<TransactionModel> getTransactionById(int transactionId) async {
    final response = await http.get(
      Uri.parse('${AppStrings.baseUrl}Transactions/$transactionId'),
      headers: await AppStrings.getHeaderApi(),
    );
    if (!_isSuccess(response.statusCode)) {
      throw Exception(_errorMessage(response));
    }
    if (response.body.trim().isEmpty) {
      throw const FormatException('The transaction response is empty.');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final item = decoded['transaction'] ?? decoded['data'] ?? decoded;
      if (item is Map) {
        return TransactionModel.fromJson(Map<String, dynamic>.from(item));
      }
    }
    throw const FormatException('Invalid transaction response.');
  }

  Future<List<TransactionModel>> _getTransactionList(Uri uri) async {
    final response = await http.get(
      uri,
      headers: await AppStrings.getHeaderApi(),
    );
    if (!_isSuccess(response.statusCode)) {
      throw Exception(_errorMessage(response));
    }
    return _decodeTransactions(response.body);
  }

  Future<http.Response> _sendMultipart({
    required String method,
    required Uri uri,
    required TransactionRequest request,
  }) async {
    final multipart = http.MultipartRequest(method, uri);
    final headers = await AppStrings.getHeaderApi();
    headers.removeWhere(
      (key, value) => key.toLowerCase() == 'content-type',
    );
    multipart.headers.addAll(headers);
    multipart.fields.addAll(request.toMultipartFields());

    for (final image in request.contractImages) {
      if (!await image.exists()) {
        throw const FormatException(
          'The selected contract image is no longer available. Please select it again.',
        );
      }
      multipart.files.add(
        await http.MultipartFile.fromPath(
          'ContractImages',
          image.path,
          contentType: _contractImageContentType(image.path),
        ),
      );
    }
    return http.Response.fromStream(await multipart.send());
  }

  http.MediaType _contractImageContentType(String path) {
    final normalizedPath = path.trim().toLowerCase();
    if (normalizedPath.endsWith('.jpg') ||
        normalizedPath.endsWith('.jpeg')) {
      return http.MediaType('image', 'jpeg');
    }
    if (normalizedPath.endsWith('.png')) {
      return http.MediaType('image', 'png');
    }
    if (normalizedPath.endsWith('.webp')) {
      return http.MediaType('image', 'webp');
    }
    throw const FormatException(
      'Unsupported contract image. Please select a JPG, PNG, or WEBP file.',
    );
  }

  List<TransactionModel> _decodeTransactions(String body) {
    if (body.trim().isEmpty) return [];
    final decoded = jsonDecode(body);
    dynamic items = decoded;
    if (decoded is Map<String, dynamic>) {
      items = decoded['transactions'] ??
          decoded['data'] ??
          decoded['items'] ??
          [];
    }
    if (items is! List) return [];
    return items
        .whereType<Map>()
        .map(
          (item) => TransactionModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  TransactionOperationResponse _decodeOperation(
    http.Response response, {
    required String fallbackMessage,
  }) {
    if (!_isSuccess(response.statusCode)) {
      throw Exception(_errorMessage(response));
    }
    if (response.body.trim().isEmpty) {
      return TransactionOperationResponse(message: fallbackMessage);
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final responseModel = TransactionOperationResponse.fromJson(decoded);
        if (decoded['message'] == null) {
          return TransactionOperationResponse(
            message: fallbackMessage,
            transactionId: responseModel.transactionId,
            contractImages: responseModel.contractImages,
          );
        }
        return responseModel;
      }
    } catch (_) {
      return TransactionOperationResponse(message: response.body);
    }
    return TransactionOperationResponse(message: fallbackMessage);
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
