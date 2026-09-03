import 'package:bloc/bloc.dart';
import 'package:car_app/features/cars/data/data_sources/remote_data_source_car.dart';
import 'package:car_app/features/cars/data/models/car_operation_response_model.dart';
import 'package:car_app/features/cars/data/models/car_request_model.dart';
import 'package:car_app/features/cars/data/models/car_response_model.dart';
import 'package:car_app/features/cars/data/models/car_search_filters.dart';
import 'package:car_app/features/cars/data/models/car_status_filters.dart';
import 'package:meta/meta.dart';

part 'car_event.dart';
part 'car_state.dart';

class CarBloc extends Bloc<CarEvent, CarState> {
  final RemoteDataSourceCar remoteDataSourceCar;

  CarBloc(this.remoteDataSourceCar) : super(CarInitial()) {
    on<GetAllCars>(_getAllCars);
    on<GetMyCars>(_getMyCars);
    on<AddCarEvent>(_addCar);
    on<EditCarEvent>(_editCar);
    on<DeleteCarEvent>(_deleteCar);
    on<SearchCarsEvent>(_searchCars);
    on<ClearCarSearchEvent>((event, emit) => emit(CarSearchInitialState()));
  }

  Future<void> _getAllCars(GetAllCars event, Emitter<CarState> emit) async {
    emit(CarLoadingState());
    try {
      final cars = await remoteDataSourceCar.getCars();
      emit(CarSuccessState(cars: cars));
    } catch (error) {
      emit(CarErrorState(message: error.toString()));
    }
  }

  Future<void> _getMyCars(GetMyCars event, Emitter<CarState> emit) async {
    emit(MyCarsLoadingState());
    try {
      final cars = await remoteDataSourceCar.getMyCars(filters: event.filters);
      emit(MyCarsSuccessState(myCars: cars, filters: event.filters));
    } catch (error) {
      emit(MyCarsErrorState(massage: error.toString()));
    }
  }

  Future<void> _addCar(AddCarEvent event, Emitter<CarState> emit) async {
    emit(AddCarLoadingState());
    try {
      final response = await remoteDataSourceCar.addCar(event.request);
      emit(AddCarSuccessState(response: response));
    } catch (error) {
      emit(AddCarErrorState(message: error.toString()));
    }
  }

  Future<void> _editCar(EditCarEvent event, Emitter<CarState> emit) async {
    emit(EditCarLoadingState());
    try {
      final response = await remoteDataSourceCar.editCar(
        event.carId,
        event.request,
      );
      emit(EditCarSuccessState(response: response));
    } catch (error) {
      emit(EditCarErrorState(message: error.toString()));
    }
  }

  Future<void> _deleteCar(DeleteCarEvent event, Emitter<CarState> emit) async {
    emit(DeleteCarLoadingState(carId: event.carId));
    try {
      final response = await remoteDataSourceCar.deleteCar(event.carId);
      emit(DeleteCarSuccessState(response: response, carId: event.carId));
    } catch (error) {
      emit(DeleteCarErrorState(message: error.toString()));
    }
  }

  Future<void> _searchCars(SearchCarsEvent event, Emitter<CarState> emit) async {
    emit(CarSearchLoadingState());
    try {
      final cars = await remoteDataSourceCar.searchCars(event.filters);
      emit(CarSearchSuccessState(cars: cars, filters: event.filters));
    } catch (error) {
      emit(CarSearchErrorState(message: error.toString()));
    }
  }
}
