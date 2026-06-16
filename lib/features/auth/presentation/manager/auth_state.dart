part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}
final class RegisterSuccessState extends AuthState {
  final RegisterResponseModel registerResponseModel ;

  RegisterSuccessState({required this.registerResponseModel});
}
final class RegisterErrorState extends AuthState {
 final String message;

  RegisterErrorState({required this.message});
}
final class RegisterLoadingState extends AuthState {}
