class CarOperationResponseModel {
  final String message;
  final int? carId;
  final bool? isApproved;
  final String? approvalStatus;
  final String? availabilityStatus;

  const CarOperationResponseModel({
    required this.message,
    this.carId,
    this.isApproved,
    this.approvalStatus,
    this.availabilityStatus,
  });

  factory CarOperationResponseModel.fromJson(Map<String, dynamic> json) {
    return CarOperationResponseModel(
      message: json['message']?.toString() ?? 'Operation completed successfully',
      carId: _asInt(json['carId']),
      isApproved: json['isApproved'] as bool?,
      approvalStatus: json['approvalStatus']?.toString(),
      availabilityStatus: json['availabilityStatus']?.toString(),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
