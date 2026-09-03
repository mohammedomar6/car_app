part of 'brands_bloc.dart';


sealed class BrandsState {}

final class BrandsInitial extends BrandsState {}

// ==========================
// GET ALL BRANDS
// ==========================

final class GetAllBrandsSuccess extends BrandsState {
  final List<BrandModel> brands;

  GetAllBrandsSuccess({
    required this.brands,
  });
}

final class GetAllBrandsError extends BrandsState {
  final String massage;

  GetAllBrandsError({
    required this.massage,
  });
}

final class GetAllBrandsLoading extends BrandsState {}

// ==========================
// ADD BRAND
// ==========================

final class AddBrandLoading extends BrandsState {}

final class AddBrandSuccess extends BrandsState {
  final AddBrandModel addBrandModel;

  AddBrandSuccess({
    required this.addBrandModel,
  });
}

final class AddBrandError extends BrandsState {
  final String massage;

  AddBrandError({
    required this.massage,
  });
}

// ==========================
// EDIT BRAND
// ==========================

final class EditBrandLoading extends BrandsState {}

final class EditBrandSuccess extends BrandsState {
  final AddBrandModel editBrandModel;

  EditBrandSuccess({
    required this.editBrandModel,
  });
}

final class EditBrandError extends BrandsState {
  final String massage;

  EditBrandError({
    required this.massage,
  });
}

// ==========================
// DELETE BRAND
// ==========================

final class DeleteBrandLoading extends BrandsState {}

final class DeleteBrandSuccess extends BrandsState {
  final DeleteBrandResponseModel deleteBrandResponseModel;

  DeleteBrandSuccess({
    required this.deleteBrandResponseModel,
  });
}

final class DeleteBrandError extends BrandsState {
  final String massage;

  DeleteBrandError({
    required this.massage,
  });
}