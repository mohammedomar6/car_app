import 'package:bloc/bloc.dart';
import 'package:car_app/features/brand/data/data_sources/remote_data_source_brand.dart';
import 'package:car_app/features/brand/data/models/add_brand_model.dart';
import 'package:car_app/features/brand/data/models/brand_model.dart';
import 'package:car_app/features/brand/data/models/brand_request_model.dart';
import 'package:car_app/features/brand/data/models/delete_brand_response_model.dart';

part 'brands_event.dart';
part 'brands_state.dart';

class BrandsBloc extends Bloc<BrandsEvent, BrandsState> {
  final RemoteDataSourceBrand remoteDataSourceBrand;

  BrandsBloc(this.remoteDataSourceBrand)
      : super(BrandsInitial()) {
    // ============================================================
    // GET ALL BRANDS
    // ============================================================

    on<GetAllBrandsEvent>(_getAllBrands);

    // ============================================================
    // ADD BRAND
    // ============================================================

    on<AddBrandEvent>(_addBrand);

    // ============================================================
    // EDIT BRAND
    // ============================================================

    on<EditBrandEvent>(_editBrand);

    // ============================================================
    // DELETE BRAND
    // ============================================================

    on<DeleteBrandEvent>(_deleteBrand);
  }

  // ============================================================
  // GET ALL BRANDS
  // ============================================================

  Future<void> _getAllBrands(
      GetAllBrandsEvent event,
      Emitter<BrandsState> emit,
      ) async {
    emit(GetAllBrandsLoading());

    try {
      final brands =
      await remoteDataSourceBrand.getBrands();

      emit(
        GetAllBrandsSuccess(
          brands: brands,
        ),
      );
    } catch (e) {
      emit(
        GetAllBrandsError(
          massage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // ADD BRAND
  // ============================================================

  Future<void> _addBrand(
      AddBrandEvent event,
      Emitter<BrandsState> emit,
      ) async {
    emit(AddBrandLoading());

    try {
      final result =
      await remoteDataSourceBrand.addBrand(
        event.brandModel,
      );

      emit(
        AddBrandSuccess(
          addBrandModel: result,
        ),
      );

      add(GetAllBrandsEvent());
    } catch (e) {
      emit(
        AddBrandError(
          massage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // EDIT BRAND
  // ============================================================

  Future<void> _editBrand(
      EditBrandEvent event,
      Emitter<BrandsState> emit,
      ) async {
    emit(EditBrandLoading());

    try {
      final result =
      await remoteDataSourceBrand.editBrand(
        event.brandId,
        event.brandModel,
      );

      emit(
        EditBrandSuccess(
          editBrandModel: result,
        ),
      );

      add(GetAllBrandsEvent());
    } catch (e) {
      emit(
        EditBrandError(
          massage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // DELETE BRAND
  // ============================================================

  Future<void> _deleteBrand(
      DeleteBrandEvent event,
      Emitter<BrandsState> emit,
      ) async {
    emit(DeleteBrandLoading());

    try {
      final result =
      await remoteDataSourceBrand.deleteBrand(
        event.brandId,
      );

      emit(
        DeleteBrandSuccess(
          deleteBrandResponseModel: result,
        ),
      );

      add(GetAllBrandsEvent());
    } catch (e) {
      emit(
        DeleteBrandError(
          massage: e.toString(),
        ),
      );
    }
  }
}