import '../../../../../core/network/api_client.dart';
import '../../../../../core/storage/auth_storage.dart';
import '../../../domain/entities/hotel_entity.dart';
import '../../models/hotel_model.dart';

class HotelRemoteDataSource {
  HotelRemoteDataSource({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;
  final AuthStorage _authStorage = AuthStorage();

  // ĐÃ XÓA @override ở đây
  Future<HotelEntity?> getById(int id) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.get(
      '/api/hotels/$id/with-location',
      accessToken: token,
    );
    final data = response['data'];
    if (data is! Map<String, dynamic>) return null;
    return HotelModel.fromJson(data);
  }

  // ĐÃ XÓA @override ở đây
  Future<(List<HotelEntity>, int)> getAll({
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.get(
      '/api/hotels/all-with-province',
      query: {'pageIndex': pageIndex, 'pageSize': pageSize},
      accessToken: token,
    );
    final data = response['data'];
    if (data is! List) return (<HotelEntity>[], 0);

    final items = data
        .whereType<Map<String, dynamic>>()
        .map(HotelModel.fromJson)
        .toList();

    int totalCount = 0;
    if (response['pagination'] != null) {
      totalCount = (response['pagination']['totalCount'] as num?)?.toInt() ?? 0;
    }
    return (items, totalCount);
  }
}