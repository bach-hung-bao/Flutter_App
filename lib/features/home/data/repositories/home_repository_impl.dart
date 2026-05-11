import '../../domain/entities/hotel_recommendation_entity.dart';
import '../../domain/entities/province_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/remote/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<HotelRecommendationEntity>> getSmartRecommendations({
    String? province,
    int topK = 10,
    String? accessToken,
  }) async {
    return await remoteDataSource.getSmartRecommendations(
      province: province,
      topK: topK,
      accessToken: accessToken,
    );
  }

  @override
  Future<List<ProvinceEntity>> getProvinces({int pageSize = 10}) async {
    return await remoteDataSource.getProvinces(pageSize: pageSize);
  }
}
