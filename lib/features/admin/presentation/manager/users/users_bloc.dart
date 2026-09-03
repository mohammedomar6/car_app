import 'package:bloc/bloc.dart';
import 'package:car_app/core/utils/massage_model.dart';
import 'package:car_app/features/admin/data/data_sources/remote_data_source_admin.dart';
import 'package:equatable/equatable.dart';

import '../../../../profile/data/models/profile_response_model.dart';

part 'users_event.dart';

part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final RemoteDataSourceAdmin remoteDataSourceAdmin;

  UsersBloc(this.remoteDataSourceAdmin)
    : super(
        UsersState(
          deleteStatus: UsersStatus.initial,
          status: UsersStatus.initial,
        ),
      ) {
    on<GetAllUser>((event, emit) async {
      emit(state.copyWith(status: UsersStatus.loading));
      try {
        final data = await remoteDataSourceAdmin.getUsers();
        emit(state.copyWith(status: UsersStatus.success, users: data));
      } on Exception catch (e) {
        emit(
          state.copyWith(status: UsersStatus.failure, message: e.toString()),
        );
      }
    });
    on<DeleteUserEvent>((event, emit) async {
      emit(state.copyWith(deleteStatus: UsersStatus.loading));
      try {
        final data = await remoteDataSourceAdmin.deleteUser(event.userId);
        emit(
          state.copyWith(deleteStatus: UsersStatus.success, massageModel: data),
        );
        add(GetAllUser());
        emit(state.copyWith(deleteStatus: UsersStatus.initial));
      } on Exception catch (e) {
        emit(
          state.copyWith(
            deleteStatus: UsersStatus.failure,
            message: e.toString(),
          ),
        );
        emit(state.copyWith(deleteStatus: UsersStatus.initial));
      }
    });
  }
}
