import 'package:equatable/equatable.dart';

class CarStatusFilters extends Equatable {
  final String? approvalStatus;
  final String? availabilityStatus;
  final int? ownerId;

  const CarStatusFilters({
    this.approvalStatus,
    this.availabilityStatus,
    this.ownerId,
  });

  bool get isEmpty => toQueryParameters().isEmpty;

  Map<String, String> toQueryParameters({bool includeOwnerId = true}) {
    return {
      if (approvalStatus != null && approvalStatus!.trim().isNotEmpty)
        'approvalStatus': approvalStatus!.trim(),
      if (availabilityStatus != null && availabilityStatus!.trim().isNotEmpty)
        'availabilityStatus': availabilityStatus!.trim(),
      if (includeOwnerId && ownerId != null) 'ownerId': ownerId.toString(),
    };
  }

  @override
  List<Object?> get props => [approvalStatus, availabilityStatus, ownerId];
}
