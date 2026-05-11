import '../../../../../core/network/api_client.dart';
import '../../../../../core/storage/auth_storage.dart';
import '../../../../hotel/data/models/hotel_model.dart';
import '../../../../hotel/domain/entities/hotel_entity.dart';

class FavoriteRemoteDataSource {
  FavoriteRemoteDataSource({ApiClient? client})
    : _client = client ?? ApiClient();

  final ApiClient _client;
  final AuthStorage _authStorage = AuthStorage();

  Future<List<HotelEntity>> getMyFavorites() async {
    final token = await _authStorage.getAccessToken();
    if (token == null || token.isEmpty) return [];

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

  Future<bool> toggleFavorite(int hotelId) async {
    final token = await _authStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const ApiException(
        'Vui lòng đăng nhập để yêu thích khách sạn.',
        401,
      );
    }

    final response = await _client.post(
      '/api/favorites/$hotelId/toggle',
      accessToken: token, // Chỉ cần giữ lại accessToken, xóa bỏ data: {}
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return (data['isFavorite'] as bool?) ??
          (data['IsFavorite'] as bool?) ??
          false;
    }
    return false;
  }

  Future<bool> isFavorite(int hotelId) async {
    final token = await _authStorage.getAccessToken();
    if (token == null || token.isEmpty) return false;

    final response = await _client.get(
      '/api/favorites/$hotelId/is-favorite',
      accessToken: token,
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return (data['isFavorite'] as bool?) ??
          (data['IsFavorite'] as bool?) ??
          false;
    }
    return false;
  }
}
