import '../entities/hotel_recommendation_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeRecommendationsUseCase {
  final HomeRepository _repository;
  const GetHomeRecommendationsUseCase(this._repository);

  Future<List<HotelRecommendationEntity>> execute({
    String? province,
    int topK = 10,
    String? accessToken,
  }) {
    return _repository.getSmartRecommendations(
      province: province,
      topK: topK,
      accessToken: accessToken,
    );
  }
}
