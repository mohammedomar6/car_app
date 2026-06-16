part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}
class RegisterEvent extends AuthEvent{
   final RegisterRequestModel registerRequestModel;

  RegisterEvent({required this.registerRequestModel});
}
