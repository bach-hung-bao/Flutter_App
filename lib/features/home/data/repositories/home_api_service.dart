import '../../../../core/network/api_client.dart';
import '../../domain/entities/hotel_recommendation_entity.dart';
import '../../domain/entities/province_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/hotel_recommendation_model.dart';
import '../models/province_model.dart';

class HomeApiService implements HomeRepository {
  HomeApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<HotelRecommendationEntity>> getSmartRecommendations({
    String? province,
    int topK = 10,
    String? accessToken,
  }) async {
    final response = await _client.get(
      '/api/recommendations/smart',
      query: {'province': province, 'topK': topK},
      accessToken: accessToken,
    );

    final data = response['data'];
    if (data is! Map<String, dynamic>) return [];
    
    final hotels = data['hotels'];
    if (hotels is! List) return [];

    return hotels
        .whereType<Map<String, dynamic>>()
        .map(HotelRecommendationModel.fromJson)
        .toList();
  }

  @override
  Future<List<ProvinceEntity>> getProvinces({int pageSize = 10}) async {
    // API lấy danh sách tỉnh thành
    final response = await _client.get(
      '/api/provinces',
      query: {'pageIndex': 1, 'pageSize': pageSize},
    );

    final data = response['data'];
    if (data is! List) return [];
    
    return data
        .whereType<Map<String, dynamic>>()
        .map(ProvinceModel.fromJson)
        .toList();
  }
}