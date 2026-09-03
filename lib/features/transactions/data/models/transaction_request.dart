import 'dart:io';

import 'package:equatable/equatable.dart';

class TransactionRequest extends Equatable {
  final int orderId;
  final double amount;
  final String paymentMethod;
  final String transactionType;
  final String status;
  final String referenceNumber;
  final String notes;
  final List<File> contractImages;

  const TransactionRequest({
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.transactionType,
    required this.status,
    required this.referenceNumber,
    required this.notes,
    this.contractImages = const [],
  });

  Map<String, String> toMultipartFields() => {
        'OrderId': orderId.toString(),
        'Amount': amount.toString(),
        'PaymentMethod': paymentMethod.trim(),
        'TransactionType': transactionType,
        'Status': status,
        'ReferenceNumber': referenceNumber.trim(),
        'Notes': notes.trim(),
      };

  @override
  List<Object?> get props => [
        orderId,
        amount,
        paymentMethod,
        transactionType,
        status,
        referenceNumber,
        notes,
        contractImages.map((file) => file.path).toList(),
      ];
}
