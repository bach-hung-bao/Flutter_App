import '../../../core/network/api_client.dart';
import '../../hotel/domain/entities/hotel_entity.dart';
import '../../hotel/data/models/hotel_model.dart';
import '../../../core/storage/auth_storage.dart';
import '../domain/repositories/search_repository.dart';

class SearchApiService implements SearchRepository {
  final ApiClient _client;
  final AuthStorage _authStorage = AuthStorage();

  SearchApiService({ApiClient? client}) : _client = client ?? ApiClient();

  @override
  Future<List<HotelEntity>> searchHotelsByName(String name) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.get(
      '/api/hotels/search',
      query: {'hotelName': name},
      accessToken: token,
    );

    final data = response['data'] ?? response;
    if (data is! List) return [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(HotelModel.fromJson)
        .toList();
  }

  @override
  Future<List<HotelEntity>> searchHotelsByProvince(String province) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.get(
      '/api/hotels/by-province',
      query: {'province': province},
      accessToken: token,
    );

    final data = response['data'] ?? response;
    if (data is! List) return [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(HotelModel.fromJson)
        .toList();
  }
}
