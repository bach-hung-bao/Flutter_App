import '../../../hotel/domain/entities/hotel_entity.dart';

abstract class SearchRepository {
  Future<List<HotelEntity>> searchHotelsByName(String name);
  Future<List<HotelEntity>> searchHotelsByProvince(String province);
  Future<List<HotelEntity>> getFeaturedHotels({int pageSize = 8});
}
