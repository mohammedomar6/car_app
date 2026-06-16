import 'package:bloc/bloc.dart';
import 'package:car_app/features/auth/data/data_sources/remote_data_source_auth.dart';
import 'package:car_app/features/auth/data/models/register_request_model.dart';
import 'package:car_app/features/auth/data/models/register_response_model.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RemoteDataSourceAuth remoteDataSourceAuth ;
  AuthBloc(this.remoteDataSourceAuth) : super(RegisterLoadingState()) {
    on<AuthEvent>((event, emit) {

    });
    on<RegisterEvent>((event, emit)async {
        emit(RegisterLoadingState());
        try {
          final data = await remoteDataSourceAuth.registerUser(event.registerRequestModel);
          emit(RegisterSuccessState(registerResponseModel: data));
        } on Exception catch (e) {
           emit(RegisterErrorState(message: e.toString()));
        }
    });
  }
}
