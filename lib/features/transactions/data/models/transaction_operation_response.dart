class TransactionOperationResponse {
  final String message;
  final int? transactionId;
  final List<String> contractImages;

  const TransactionOperationResponse({
    required this.message,
    this.transactionId,
    this.contractImages = const [],
  });

  factory TransactionOperationResponse.fromJson(Map<String, dynamic> json) {
    final rawImages = json['contractImages'];
    return TransactionOperationResponse(
      message: json['message']?.toString() ?? 'Operation completed successfully.',
      transactionId: _asNullableInt(json['transactionId'] ?? json['id']),
      contractImages: rawImages is List
          ? rawImages
              .where((item) => item != null)
              .map((item) => item is Map
                  ? (item['imageUrl'] ?? item['url'])?.toString() ?? ''
                  : item.toString())
              .where((url) => url.isNotEmpty)
              .toList()
          : const [],
    );
  }
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
