abstract class FavoriteEvent {
  const FavoriteEvent();
}

class LoadFavoritesEvent extends FavoriteEvent {}

class ToggleFavoriteInListEvent extends FavoriteEvent {
  final int hotelId;

  const ToggleFavoriteInListEvent(this.hotelId);
}
