import 'package:equatable/equatable.dart';

import '../../../cars/data/models/car_response_model.dart';

enum FavoriteStatus { initial, loading, success, failure }

class FavoriteState extends Equatable {
  final FavoriteStatus status;
  final FavoriteStatus toggleStatus;
  final List<CarResponseModel> favorites;
  final Set<int> favoriteIds;
  final Set<int> togglingIds;
  final String message;

  const FavoriteState({
    this.status = FavoriteStatus.initial,
    this.toggleStatus = FavoriteStatus.initial,
    this.favorites = const [],
    this.favoriteIds = const {},
    this.togglingIds = const {},
    this.message = '',
  });

  bool isFavorite(int carId) => favoriteIds.contains(carId);

  bool isToggling(int carId) => togglingIds.contains(carId);

  FavoriteState copyWith({
    FavoriteStatus? status,
    FavoriteStatus? toggleStatus,
    List<CarResponseModel>? favorites,
    Set<int>? favoriteIds,
    Set<int>? togglingIds,
    String? message,
  }) {
    return FavoriteState(
      status: status ?? this.status,
      toggleStatus: toggleStatus ?? this.toggleStatus,
      favorites: favorites ?? this.favorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      togglingIds: togglingIds ?? this.togglingIds,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        toggleStatus,
        favorites,
        favoriteIds,
        togglingIds,
        message,
      ];
}
