import '../../../hotel/domain/entities/hotel_entity.dart';
import '../repositories/favorite_repository.dart';

class GetFavoritesUseCase {
  final FavoriteRepository _repository;
  const GetFavoritesUseCase(this._repository);

  Future<List<HotelEntity>> execute() => _repository.getMyFavorites();
}
