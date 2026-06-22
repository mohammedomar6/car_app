import 'package:bloc/bloc.dart';
import 'package:car_app/features/cars/data/data_sources/remote_data_source_car.dart';
import 'package:car_app/features/cars/data/models/car_response_model.dart';
import 'package:meta/meta.dart';

part 'car_event.dart';
part 'car_state.dart';

class CarBloc extends Bloc<CarEvent, CarState> {
  final RemoteDataSourceCar remoteDataSourceCar ;
  CarBloc(this.remoteDataSourceCar) : super(CarInitial()) {
    on<CarEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<GetAllCars>((event, emit)async {
      emit(CarLoadingState());
      try {
        final  data = await remoteDataSourceCar.getCars();
        emit(CarSuccessState(cars: data));
      } on Exception catch (e) {
         emit(CarErrorState(message: e.toString()));
      }
    },);
  }
}
