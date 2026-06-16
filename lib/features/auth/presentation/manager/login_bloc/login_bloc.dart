import 'package:bloc/bloc.dart';
import 'package:car_app/features/auth/data/data_sources/remote_data_source_auth.dart';
import 'package:car_app/features/auth/data/models/login_request_model.dart';
import 'package:car_app/features/auth/data/models/login_response_model.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final RemoteDataSourceAuth remoteDataSourceAuth ;
  LoginBloc(this.remoteDataSourceAuth) : super(LoginInitial()) {
    on<LoginEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<LogiEvent>((event, emit) async{
       emit(LoginLoading());
       try {
         final data= await remoteDataSourceAuth.loginUser(event.requestModel);
         emit(LoginSuccess(responseModel: data));
       } on Exception catch (e) {
         // TODO
         emit(LoginError(message: e.toString()));
       }

    },);
  }
}
