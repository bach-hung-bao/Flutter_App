import '../repositories/search_repository.dart';
import '../../../hotel/domain/entities/hotel_entity.dart';

class SearchHotelsByNameUseCase {
  final SearchRepository _repository;
  const SearchHotelsByNameUseCase(this._repository);

  Future<List<HotelEntity>> execute(String name) {
    return _repository.searchHotelsByName(name);
  }
}
