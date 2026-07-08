import 'package:bloc/bloc.dart';
import 'package:car_app/features/profile/data/data_sources/remote_data_source_profile.dart';
import 'package:car_app/features/profile/data/models/profile_response_model.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
 final RemoteDataSourceProfile remoteDataSourceProfile;
  ProfileBloc(this.remoteDataSourceProfile) : super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<GetProfileEvent>((event, emit)async {
      emit(ProfileLoadingState());
      try {
        final data=await remoteDataSourceProfile.getProfile();
        emit(ProfileSuccessState(profileResponseModel: data));
      } on Exception catch (e) {
       emit(ProfileErrorState(message: e.toString()));
      }
    },);
  }
}
