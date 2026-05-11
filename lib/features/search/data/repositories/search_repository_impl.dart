import '../../../hotel/domain/entities/hotel_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/remote/search_remote_data_source.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<HotelEntity>> searchHotelsByName(String name) async {
    return await remoteDataSource.searchHotelsByName(name);
  }

  @override
  Future<List<HotelEntity>> searchHotelsByProvince(String province) async {
    return await remoteDataSource.searchHotelsByProvince(province);
  }

  @override
  Future<List<HotelEntity>> getFeaturedHotels({int pageSize = 8}) async {
    return await remoteDataSource.getFeaturedHotels(pageSize: pageSize);
  }
}
