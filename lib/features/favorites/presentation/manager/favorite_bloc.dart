import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data_sources/favorite_remote_data_source.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRemoteDataSource remoteDataSource;

  FavoriteBloc({required this.remoteDataSource}) : super(const FavoriteState()) {
    on<GetMyFavoritesEvent>(_getMyFavorites);
    on<ToggleFavoriteEvent>(_toggleFavorite);
  }

  Future<void> _getMyFavorites(
    GetMyFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(state.copyWith(status: FavoriteStatus.loading));

    try {
      final favorites = await remoteDataSource.getMyFavorites();
      emit(
        state.copyWith(
          status: FavoriteStatus.success,
          favorites: favorites,
          favoriteIds: favorites.map((car) => car.carId).toSet(),
          message: '',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: FavoriteStatus.failure,
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _toggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    if (state.isToggling(event.carId)) return;

    final oldFavoriteIds = Set<int>.from(state.favoriteIds);
    final oldFavorites = List.of(state.favorites);
    final oldStatus = state.status;
    final wasFavorite = oldFavoriteIds.contains(event.carId);
    final optimisticIds = Set<int>.from(oldFavoriteIds);
    final optimisticFavorites = List.of(oldFavorites);
    final togglingIds = Set<int>.from(state.togglingIds)..add(event.carId);

    if (wasFavorite) {
      optimisticIds.remove(event.carId);
      optimisticFavorites.removeWhere((car) => car.carId == event.carId);
    } else {
      optimisticIds.add(event.carId);
      if (event.car != null &&
          !optimisticFavorites.any((car) => car.carId == event.carId)) {
        optimisticFavorites.insert(0, event.car!);
      }
    }

    // Update every heart immediately, before waiting for the network.
    emit(
      state.copyWith(
        status: FavoriteStatus.success,
        toggleStatus: FavoriteStatus.loading,
        favoriteIds: optimisticIds,
        favorites: optimisticFavorites,
        togglingIds: togglingIds,
        message: '',
      ),
    );

    try {
      final message = await remoteDataSource.toggleFavorite(event.carId);
      final completedIds = Set<int>.from(state.togglingIds)..remove(event.carId);

      emit(
        state.copyWith(
          toggleStatus: FavoriteStatus.success,
          togglingIds: completedIds,
          message: message,
        ),
      );
    } catch (error) {
      final completedIds = Set<int>.from(state.togglingIds)..remove(event.carId);
      final revertedIds = Set<int>.from(state.favoriteIds);
      final revertedFavorites = List.of(state.favorites);

      if (wasFavorite) {
        revertedIds.add(event.carId);
        final oldIndex = oldFavorites.indexWhere((car) => car.carId == event.carId);
        final alreadyRestored = revertedFavorites.any(
          (car) => car.carId == event.carId,
        );
        if (oldIndex >= 0 && !alreadyRestored) {
          final insertIndex = oldIndex > revertedFavorites.length
              ? revertedFavorites.length
              : oldIndex;
          revertedFavorites.insert(insertIndex, oldFavorites[oldIndex]);
        }
      } else {
        revertedIds.remove(event.carId);
        revertedFavorites.removeWhere((car) => car.carId == event.carId);
      }

      // Roll back both the heart and the favorites list if the API fails.
      emit(
        state.copyWith(
          status: oldStatus,
          toggleStatus: FavoriteStatus.failure,
          favoriteIds: revertedIds,
          favorites: revertedFavorites,
          togglingIds: completedIds,
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
