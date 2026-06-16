part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}
class LogiEvent extends LoginEvent{
 final  LoginRequestModel requestModel  ;

  LogiEvent({required this.requestModel});
}
