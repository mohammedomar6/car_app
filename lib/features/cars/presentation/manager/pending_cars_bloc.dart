import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../admin/data/data_sources/remote_data_source_admin.dart';

import 'pending_cars_event.dart';
import 'pending_cars_state.dart';

class PendingCarsBloc
    extends Bloc<PendingCarsEvent, PendingCarsState> {

  final RemoteDataSourceAdmin remoteDataSourceAdmin;

  PendingCarsBloc({
    required this.remoteDataSourceAdmin,
  }) : super(const PendingCarsState()) {

    on<GetPendingCarsEvent>((event, emit) async {
      emit(
        state.copyWith(
          status: PendingCarsStatus.loading,
          filters: event.filters,
          message: '',
        ),
      );

      try {
        final cars =
        await remoteDataSourceAdmin.getAdminCars(filters: event.filters);

        emit(
          state.copyWith(
            status: PendingCarsStatus.success,
            cars: cars,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: PendingCarsStatus.failure,
            message: e.toString(),
          ),
        );
      }
    });
  }
}
