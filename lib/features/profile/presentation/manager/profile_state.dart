part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}
final class ProfileLoadingState extends ProfileState {}
final class ProfileSuccessState extends ProfileState {
 final ProfileResponseModel profileResponseModel;

  ProfileSuccessState({required this.profileResponseModel});
}
final class ProfileErrorState extends ProfileState {
  final String message;

  ProfileErrorState({required this.message});
}
final class ChangePasswordInitial extends ProfileState {}
final class ChangePasswordLoadingState extends ProfileState {}
final class ChangePasswordSuccessState extends ProfileState {
  final ChangeProfileResponseModel changeProfileResponseModel;

  ChangePasswordSuccessState({required this.changeProfileResponseModel});

}
final class ChangePasswordErrorState extends ProfileState {
  final String message;

  ChangePasswordErrorState({required this.message});
}
final class EditProfileInitial extends ProfileState {}
final class EditProfileLoadingState extends ProfileState {}
final class EditProfileSuccessState extends ProfileState {
  final ChangeProfileResponseModel changeProfileResponseModel;

  EditProfileSuccessState({required this.changeProfileResponseModel});

}
final class EditProfileErrorState extends ProfileState {
  final String massage ;

  EditProfileErrorState({required this.massage});
}
class DeleteAccountLoadingState extends ProfileState {}

class DeleteAccountSuccessState extends ProfileState {
  final MassageModel massageModel;

  DeleteAccountSuccessState({
    required this.massageModel,
  });
}

class DeleteAccountErrorState extends ProfileState {
  final String message;

  DeleteAccountErrorState({
    required this.message,
  });
}