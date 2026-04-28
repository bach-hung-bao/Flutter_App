import '../repositories/search_repository.dart';
import '../../../hotel/domain/entities/hotel_entity.dart';

class SearchHotelsByProvinceUseCase {
  final SearchRepository _repository;
  const SearchHotelsByProvinceUseCase(this._repository);

  Future<List<HotelEntity>> execute(String province) {
    return _repository.searchHotelsByProvince(province);
  }
}
