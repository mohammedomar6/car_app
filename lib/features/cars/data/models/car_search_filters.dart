class CarSearchFilters {
  final int? brandId;
  final String? model;
  final double? minPrice;
  final double? maxPrice;
  final int? year;
  final String? fuelType;
  final String? gearType;

  const CarSearchFilters({
    this.brandId,
    this.model,
    this.minPrice,
    this.maxPrice,
    this.year,
    this.fuelType,
    this.gearType,
  });

  bool get isEmpty => toQueryParameters().isEmpty;

  Map<String, String> toQueryParameters() {
    return {
      if (brandId != null) 'brandId': brandId.toString(),
      if (model != null && model!.trim().isNotEmpty) 'model': model!.trim(),
      if (minPrice != null) 'minPrice': minPrice.toString(),
      if (maxPrice != null) 'maxPrice': maxPrice.toString(),
      if (year != null) 'year': year.toString(),
      if (fuelType != null && fuelType!.trim().isNotEmpty)
        'fuelType': fuelType!.trim(),
      if (gearType != null && gearType!.trim().isNotEmpty)
        'gearType': gearType!.trim(),
    };
  }
}
