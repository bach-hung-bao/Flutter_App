import '../../domain/entities/hotel_entity.dart';
import '../../domain/repositories/hotel_repository.dart';
import '../datasources/remote/hotel_remote_data_source.dart';

class HotelRepositoryImpl implements HotelRepository {
  final HotelRemoteDataSource remoteDataSource;

  HotelRepositoryImpl({required this.remoteDataSource});

  @override
  Future<HotelEntity?> getById(int id) async {
    return await remoteDataSource.getById(id);
  }

  @override
  Future<(List<HotelEntity>, int)> getAll({
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    return await remoteDataSource.getAll(
      pageIndex: pageIndex,
      pageSize: pageSize,
    );
  }
}
