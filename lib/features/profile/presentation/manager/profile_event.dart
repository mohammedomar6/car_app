part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}
class GetProfileEvent extends ProfileEvent{}
class DeleteAccountEvent extends ProfileEvent {}
class EditProfileEvent extends ProfileEvent{
  final ProfileResponseModel request  ;

  EditProfileEvent({required this.request});

}
class ChangePasswordEvent extends ProfileEvent{
  final ChangePasswordRequestModel changePasswordRequestModel;

  ChangePasswordEvent({required this.changePasswordRequestModel});

}

