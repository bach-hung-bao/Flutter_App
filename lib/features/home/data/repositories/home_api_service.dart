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
    List<HotelRecommendationEntity> results = [];

    try {
      // 1. Gọi API Gợi ý
      final response = await _client.get(
        '/api/recommendations/smart',
        query: {'province': province, 'topK': topK},
        accessToken: accessToken,
      );

      final data = response['data'];
      if (data != null &&
          data is Map<String, dynamic> &&
          data['hotels'] is List) {
        results = (data['hotels'] as List)
            .whereType<Map<String, dynamic>>()
            .map(HotelRecommendationModel.fromJson)
            .toList();
      }
    } catch (_) {}

    // 2. Dự phòng (Fallback): Nếu chưa có gợi ý, dùng gợi ý cho người dùng mới
    if (results.isEmpty) {
      try {
        final Map<String, dynamic> query = {'topK': topK};
        if (province != null && province.isNotEmpty && province != 'Tất cả') {
          query['province'] = province;
        }

        final fallbackRes = await _client.get(
          '/api/recommendations/new-user',
          query: query,
          accessToken: accessToken,
        );

        final fallbackData = fallbackRes['data'];
        if (fallbackData is Map && fallbackData['hotels'] is List) {
          results = (fallbackData['hotels'] as List)
              .whereType<Map<String, dynamic>>()
              .map(HotelRecommendationModel.fromJson)
              .toList();
        }
      } catch (_) {}
    }

    if (results.isEmpty &&
        province != null &&
        province.isNotEmpty &&
        province != 'Tất cả') {
      try {
        final fallbackRes = await _client.get(
          '/api/hotels/all-with-province',
          query: {'pageIndex': 1, 'pageSize': topK},
          accessToken: accessToken,
        );

        final list = _extractList(fallbackRes['data']);
        results = list
            .whereType<Map<String, dynamic>>()
            .map(HotelRecommendationModel.fromJson)
            .toList();
      } catch (_) {}
    }

    if (results.isEmpty) {
      try {
        final fallbackRes = await _client.get(
          '/api/hotels/all-with-province',
          query: {'pageIndex': 1, 'pageSize': topK},
          accessToken: accessToken,
        );

        final list = _extractList(fallbackRes['data']);
        results = list
            .whereType<Map<String, dynamic>>()
            .map(HotelRecommendationModel.fromJson)
            .toList();
      } catch (_) {}
    }

    return results;
  }

  @override
  Future<List<ProvinceEntity>> getProvinces({int pageSize = 10}) async {
    try {
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
    } catch (_) {
      return [];
    }
  }

  List _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['items'] is List) return data['items'] as List;
    if (data is Map && data['data'] is List) return data['data'] as List;
    return [];
  }
}
