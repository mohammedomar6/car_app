part of 'login_bloc.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}
final class LoginSuccess extends LoginState {
 final LoginResponseModel responseModel ;

  LoginSuccess({required this.responseModel});
 }
final class LoginError extends LoginState {
  final String message ;

  LoginError({required this.message});
}
final class LoginLoading extends LoginState {}
