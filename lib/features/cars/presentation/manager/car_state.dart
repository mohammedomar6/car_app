part of 'car_bloc.dart';

@immutable
sealed class CarState {}

final class CarInitial extends CarState {}
final class CarSuccessState extends CarState {
  final List<CarResponseModel> cars ;

  CarSuccessState({required this.cars});

}
final class CarErrorState extends CarState {
  final String message ;

  CarErrorState({required this.message});
}
final class CarLoadingState extends CarState {}
final class MyCarsSuccessState extends CarState{
final  List<CarResponseModel> myCars;

  MyCarsSuccessState({required this.myCars});
}
final class MyCarsLoadingState extends CarState{}
final class MyCarsErrorState extends CarState{
  final  String massage ;

  MyCarsErrorState({required this.massage});
}
