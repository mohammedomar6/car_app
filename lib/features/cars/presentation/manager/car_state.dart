part of 'car_bloc.dart';

@immutable
sealed class CarState {}

final class CarInitial extends CarState {}
final class CarLoadingState extends CarState {}

final class CarSuccessState extends CarState {
  final List<CarResponseModel> cars;
  CarSuccessState({required this.cars});
}

final class CarErrorState extends CarState {
  final String message;
  CarErrorState({required this.message});
}

final class MyCarsLoadingState extends CarState {}

final class MyCarsSuccessState extends CarState {
  final List<CarResponseModel> myCars;
  final CarStatusFilters filters;

  MyCarsSuccessState({
    required this.myCars,
    this.filters = const CarStatusFilters(),
  });
}

final class MyCarsErrorState extends CarState {
  final String massage;
  MyCarsErrorState({required this.massage});
}

final class AddCarLoadingState extends CarState {}

final class AddCarSuccessState extends CarState {
  final CarOperationResponseModel response;
  AddCarSuccessState({required this.response});
}

final class AddCarErrorState extends CarState {
  final String message;
  AddCarErrorState({required this.message});
}

final class EditCarLoadingState extends CarState {}

final class EditCarSuccessState extends CarState {
  final CarOperationResponseModel response;
  EditCarSuccessState({required this.response});
}

final class EditCarErrorState extends CarState {
  final String message;
  EditCarErrorState({required this.message});
}

final class DeleteCarLoadingState extends CarState {
  final int carId;
  DeleteCarLoadingState({required this.carId});
}

final class DeleteCarSuccessState extends CarState {
  final CarOperationResponseModel response;
  final int carId;
  DeleteCarSuccessState({required this.response, required this.carId});
}

final class DeleteCarErrorState extends CarState {
  final String message;
  DeleteCarErrorState({required this.message});
}

final class CarSearchInitialState extends CarState {}
final class CarSearchLoadingState extends CarState {}

final class CarSearchSuccessState extends CarState {
  final List<CarResponseModel> cars;
  final CarSearchFilters filters;
  CarSearchSuccessState({required this.cars, required this.filters});
}

final class CarSearchErrorState extends CarState {
  final String message;
  CarSearchErrorState({required this.message});
}
