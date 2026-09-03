part of 'brands_bloc.dart';

sealed class BrandsEvent {}

// ============================================================
// GET ALL BRANDS
// ============================================================

final class GetAllBrandsEvent extends BrandsEvent {}


// ============================================================
// ADD BRAND
// ============================================================

final class AddBrandEvent extends BrandsEvent {
  final BrandRequestModel brandModel;

  AddBrandEvent({
    required this.brandModel,
  });
}


// ============================================================
// EDIT BRAND
// ============================================================

final class EditBrandEvent extends BrandsEvent {
  final int brandId;
  final BrandRequestModel brandModel;

  EditBrandEvent({
    required this.brandId,
    required this.brandModel,
  });
}


// ============================================================
// DELETE BRAND
// ============================================================

final class DeleteBrandEvent extends BrandsEvent {
  final int brandId;

  DeleteBrandEvent({
    required this.brandId,
  });
}