part of 'brands_bloc.dart';

@immutable
sealed class BrandsEvent {}
  class GetAllBrandsEvent extends BrandsEvent{}
  class AddBrandEvent extends BrandsEvent{
    final  BrandRequestModel  brandModel ;

  AddBrandEvent({required this.brandModel});
  }

  class DeleteBrandEvent extends BrandsEvent{
    final  int  brandId ;

  DeleteBrandEvent({required this.brandId});

  }