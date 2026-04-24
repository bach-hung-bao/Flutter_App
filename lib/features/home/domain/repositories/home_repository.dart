import '../entities/hotel_recommendation_entity.dart';
import '../entities/province_entity.dart';

abstract class HomeRepository {
  Future<List<HotelRecommendationEntity>> getSmartRecommendations({
    String? province,
    int topK = 10,
    String? accessToken,
  });

  Future<List<ProvinceEntity>> getProvinces({int pageSize = 8});
}
