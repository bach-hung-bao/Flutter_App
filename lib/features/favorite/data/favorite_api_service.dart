import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_storage.dart';
import '../../hotel/data/models/hotel_model.dart';
import '../../hotel/domain/entities/hotel_entity.dart';
import '../domain/repositories/favorite_repository.dart';

class FavoriteApiService implements FavoriteRepository {
  FavoriteApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;
  final AuthStorage _authStorage = AuthStorage();

  @override
  Future<List<HotelEntity>> getMyFavorites() async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.get(
      '/api/favorites/my-favorites',
      accessToken: token,
    );
    final data = response['data'];
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(HotelModel.fromJson)
        .toList();
  }

  @override
  Future<bool> toggleFavorite(int hotelId) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.post(
      '/api/favorites/$hotelId/toggle',
      accessToken: token,
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return (data['isFavorite'] as bool?) ?? false;
    }
    return false;
  }

  @override
  Future<bool> isFavorite(int hotelId) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.get(
      '/api/favorites/$hotelId/is-favorite',
      accessToken: token,
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return (data['isFavorite'] as bool?) ?? false;
    }
    return false;
  }
}
