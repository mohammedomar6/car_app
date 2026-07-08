part of 'car_bloc.dart';

@immutable
sealed class CarEvent {}
class GetAllCars extends CarEvent{}
class GetMyCars extends CarEvent{}