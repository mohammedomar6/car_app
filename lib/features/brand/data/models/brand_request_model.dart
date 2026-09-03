import 'dart:io';

class BrandRequestModel {
  final String brandName;
  final File? imageFile;

  const BrandRequestModel({
    required this.brandName,
    this.imageFile,
  });
}