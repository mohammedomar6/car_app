part of 'car_bloc.dart';

@immutable
sealed class CarEvent {}

final class GetAllCars extends CarEvent {}

final class GetMyCars extends CarEvent {
  final CarStatusFilters filters;

  GetMyCars({this.filters = const CarStatusFilters()});
}

final class AddCarEvent extends CarEvent {
  final CarRequestModel request;

  AddCarEvent({required this.request});
}

final class EditCarEvent extends CarEvent {
  final int carId;
  final CarRequestModel request;

  EditCarEvent({required this.carId, required this.request});
}

final class DeleteCarEvent extends CarEvent {
  final int carId;

  DeleteCarEvent({required this.carId});
}

final class SearchCarsEvent extends CarEvent {
  final CarSearchFilters filters;

  SearchCarsEvent({required this.filters});
}

final class ClearCarSearchEvent extends CarEvent {}
