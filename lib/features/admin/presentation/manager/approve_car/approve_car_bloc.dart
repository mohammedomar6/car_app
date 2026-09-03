import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../data/data_sources/remote_data_source_admin.dart';
import 'approve_car_event.dart';
import 'approve_car_state.dart';

class ApproveCarBloc
    extends Bloc<ApproveCarEvent, ApproveCarState> {
  final RemoteDataSourceAdmin remoteDataSourceAdmin;

  ApproveCarBloc({
    required this.remoteDataSourceAdmin,
  }) : super(const ApproveCarState()) {
    on<ApproveCar>(_approveCar);
    on<RejectCar>(_rejectCar);
  }

  Future<void> _approveCar(
      ApproveCar event,
      Emitter<ApproveCarState> emit,
      ) async {
    if (state.status == ApproveCarStatus.loading) return;
    emit(
      state.copyWith(
        status: ApproveCarStatus.loading,
        processingCarId: event.request.id,
        action: 'approve',
        message: '',
      ),
    );

    try {
      final response = await remoteDataSourceAdmin.approveCar(
        event.request,
      );

      emit(
        state.copyWith(
          status: ApproveCarStatus.success,
          response: response,
          message: response.message ?? 'Car approved successfully.',
          clearProcessingCarId: true,
          clearAction: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ApproveCarStatus.failure,
          message: e.toString(),
          clearProcessingCarId: true,
          clearAction: true,
        ),
      );
    }
  }

  Future<void> _rejectCar(
    RejectCar event,
    Emitter<ApproveCarState> emit,
  ) async {
    if (state.status == ApproveCarStatus.loading) return;
    emit(
      state.copyWith(
        status: ApproveCarStatus.loading,
        processingCarId: event.request.carId,
        action: 'reject',
        message: '',
      ),
    );

    try {
      final response = await remoteDataSourceAdmin.rejectCar(event.request);
      emit(
        state.copyWith(
          status: ApproveCarStatus.success,
          response: response,
          message: response.message ?? 'Car rejected successfully.',
          clearProcessingCarId: true,
          clearAction: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ApproveCarStatus.failure,
          message: e.toString().replaceFirst('Exception: ', ''),
          clearProcessingCarId: true,
          clearAction: true,
        ),
      );
    }
  }
}
