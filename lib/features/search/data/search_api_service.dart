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

  Future<List<HotelEntity>> getFeaturedHotels({int pageSize = 8}) async {
    final response = await _client.get(
      '/api/hotels/all-with-province',
      query: {'pageIndex': 1, 'pageSize': pageSize},
    );

    final data = response['data'];
    final list = _extractList(data);
    return list
        .whereType<Map<String, dynamic>>()
        .map(HotelModel.fromJson)
        .toList();
  }

  List _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['items'] is List) return data['items'] as List;
    if (data is Map && data['data'] is List) return data['data'] as List;
    return [];
  }
}
