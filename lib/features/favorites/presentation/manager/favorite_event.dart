import 'package:equatable/equatable.dart';

import '../../../cars/data/models/car_response_model.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object?> get props => [];
}

/// جلب السيارات المفضلة
class GetMyFavoritesEvent extends FavoriteEvent {
  const GetMyFavoritesEvent();
}

/// إضافة / إزالة السيارة من المفضلة
class ToggleFavoriteEvent extends FavoriteEvent {
  final int carId;
  final CarResponseModel? car;

  const ToggleFavoriteEvent({
    required this.carId,
    this.car,
  });

  @override
  List<Object?> get props => [carId, car];
}
