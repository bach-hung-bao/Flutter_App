import '../../../hotel/domain/entities/hotel_entity.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/remote/favorite_remote_data_source.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource remoteDataSource;

  FavoriteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<HotelEntity>> getMyFavorites() async {
    return await remoteDataSource.getMyFavorites();
  }

  @override
  Future<bool> toggleFavorite(int hotelId) async {
    return await remoteDataSource.toggleFavorite(hotelId);
  }

  @override
  Future<bool> isFavorite(int hotelId) async {
    return await remoteDataSource.isFavorite(hotelId);
  }
}
