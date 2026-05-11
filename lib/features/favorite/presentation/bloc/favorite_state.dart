import '../../../hotel/domain/entities/hotel_entity.dart';

abstract class FavoriteState {
  const FavoriteState();
}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<HotelEntity> favorites;

  const FavoriteLoaded(this.favorites);
}

class FavoriteError extends FavoriteState {
  final String message;
  final bool isAuthError;

  const FavoriteError(this.message, {this.isAuthError = false});
}
