import '../entities/hotel_entity.dart';

abstract class HotelRepository {
  Future<HotelEntity?> getById(int id);
  Future<(List<HotelEntity>, int)> getAll({int pageIndex = 1, int pageSize = 20});
}
