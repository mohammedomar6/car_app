import 'package:equatable/equatable.dart';

class RejectCarRequestModel extends Equatable {
  final int carId;
  final String adminNotes;

  const RejectCarRequestModel({
    required this.carId,
    required this.adminNotes,
  });

  @override
  List<Object> get props => [carId, adminNotes];
}
