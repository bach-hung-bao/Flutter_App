import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_storage.dart';
import '../domain/entities/hotel_entity.dart';
import '../domain/repositories/hotel_repository.dart';
import 'models/hotel_model.dart';

class HotelApiService implements HotelRepository {
  HotelApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;
  final AuthStorage _authStorage = AuthStorage();

  @override
  Future<HotelEntity?> getById(int id) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.get(
      '/api/hotels/$id',
      accessToken: token,
    );
    final data = response['data'];
    if (data is! Map<String, dynamic>) return null;
    return HotelModel.fromJson(data);
  }

  @override
  Future<(List<HotelEntity>, int)> getAll({
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.get(
      '/api/hotels',
      query: {'pageIndex': pageIndex, 'pageSize': pageSize},
      accessToken: token,
    );
    final data = response['data'];
    if (data is! List) return (<HotelEntity>[], 0);
    final total = (response['totalCount'] as num?)?.toInt() ?? 0;
    final items = data
        .whereType<Map<String, dynamic>>()
        .map(HotelModel.fromJson)
        .toList();
    return (items, total);
  }
}
