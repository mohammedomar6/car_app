import 'package:bloc/bloc.dart';
import 'package:car_app/features/profile/data/data_sources/remote_data_source_profile.dart';
import 'package:car_app/features/profile/data/models/change_password_request_model.dart';
import 'package:car_app/features/profile/data/models/change_profile_response_model.dart';
import 'package:car_app/features/profile/data/models/profile_response_model.dart';
import 'package:meta/meta.dart';

import '../../../../core/utils/massage_model.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final RemoteDataSourceProfile remoteDataSourceProfile;
  ProfileResponseModel? currentProfile;

  ProfileBloc(this.remoteDataSourceProfile) : super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<GetProfileEvent>((event, emit) async {
      emit(ProfileLoadingState());
      try {
        final data = await remoteDataSourceProfile.getProfile();
        currentProfile = data;
        emit(ProfileSuccessState(profileResponseModel: data));
      } on Exception catch (e) {
        emit(ProfileErrorState(message: e.toString()));
      }
    });
    on<ChangePasswordEvent>((event, emit) async {
      emit(ChangePasswordLoadingState());
      try {
        final data = await remoteDataSourceProfile.changePassword(
          event.changePasswordRequestModel,
        );
        emit(ChangePasswordSuccessState(changeProfileResponseModel: data));
      } on Exception catch (e) {
        emit(ChangePasswordErrorState(message: e.toString()));
      }
    });
    on<EditProfileEvent>((event, emit) async {
      emit(EditProfileLoadingState());
      try {
        final data = await remoteDataSourceProfile.changeProfile(event.request);

        emit(EditProfileSuccessState(changeProfileResponseModel: data));
      } on Exception catch (e) {
        emit(EditProfileErrorState(massage: e.toString()));
      }
    });
    on<DeleteAccountEvent>((event, emit) async {
      emit(DeleteAccountLoadingState());

      try {
        final data =
        await remoteDataSourceProfile.deleteAccount();

        emit(
          DeleteAccountSuccessState(
            massageModel: data,
          ),
        );
      } on Exception catch (e) {
        emit(
          DeleteAccountErrorState(
            message: e.toString(),
          ),
        );
      }
    });
  }
}
