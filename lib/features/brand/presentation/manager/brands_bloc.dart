import 'package:bloc/bloc.dart';
import 'package:car_app/features/brand/data/data_sources/remote_data_source_brand.dart';
import 'package:car_app/features/brand/data/models/add_brand_model.dart';
import 'package:car_app/features/brand/data/models/brand_model.dart';
import 'package:car_app/features/brand/data/models/brand_request_model.dart';
import 'package:car_app/features/brand/data/models/delete_brand_response_model.dart';
import 'package:flutter/material.dart';


part 'brands_event.dart';
part 'brands_state.dart';

class BrandsBloc extends Bloc<BrandsEvent, BrandsState> {
  final RemoteDataSourceBrand remoteDataSourceBrand;
  BrandsBloc(this.remoteDataSourceBrand) : super(BrandsInitial()) {
    on<GetAllBrandsEvent>((event, emit) async{
      emit(GetAllBrandsLoading());
         try {
           final data =await remoteDataSourceBrand.getBrands();
           emit(GetAllBrandsSuccess(brands: data));
         } on Exception catch (e) {
           emit(GetAllBrandsError(massage: e.toString()));
         }

    },);
    on<AddBrandEvent>((event, emit)async {
      emit(AddBrandLoading());
      try {
        final data =await remoteDataSourceBrand.addBrand(event.brandModel);
        emit(AddBrandSuccess(addBrandModel: data));
        add(GetAllBrandsEvent());
      } on Exception catch (e) {
        emit(AddBrandError(massage: e.toString()));
      }
    },);
    on<DeleteBrandEvent>((event, emit)async {
       emit(DeleteBrandLoading());
      try {
        final data =await remoteDataSourceBrand.deleteBrand(event.brandId);
        emit(DeleteBrandSuccess(deleteBrandResponseModel: data));
        add(GetAllBrandsEvent());
      } on Exception catch (e) {
        emit(DeleteBrandError(massage: e.toString()));
      }
    },);
  }
}
