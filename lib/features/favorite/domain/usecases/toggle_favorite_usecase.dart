import '../repositories/favorite_repository.dart';

class ToggleFavoriteUseCase {
  final FavoriteRepository _repository;
  const ToggleFavoriteUseCase(this._repository);

  /// Returns true if now favorited, false if removed
  Future<bool> execute(int hotelId) => _repository.toggleFavorite(hotelId);
}
