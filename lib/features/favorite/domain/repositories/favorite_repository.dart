import '../../../hotel/domain/entities/hotel_entity.dart';

abstract class FavoriteRepository {
  Future<List<HotelEntity>> getMyFavorites();
  Future<bool> toggleFavorite(int hotelId);
  Future<bool> isFavorite(int hotelId);
}
