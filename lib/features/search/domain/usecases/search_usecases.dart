import '../../../hotel/domain/entities/hotel_entity.dart';
import '../repositories/search_repository.dart';

class SearchHotelsByNameUseCase {
  final SearchRepository _repository;
  const SearchHotelsByNameUseCase(this._repository);

  Future<List<HotelEntity>> execute(String name) {
    return _repository.searchHotelsByName(name);
  }
}

class SearchHotelsByProvinceUseCase {
  final SearchRepository _repository;
  const SearchHotelsByProvinceUseCase(this._repository);

  Future<List<HotelEntity>> execute(String province) {
    return _repository.searchHotelsByProvince(province);
  }
}

class GetFeaturedHotelsUseCase {
  final SearchRepository _repository;
  const GetFeaturedHotelsUseCase(this._repository);

  Future<List<HotelEntity>> execute({int pageSize = 8}) {
    return _repository.getFeaturedHotels(pageSize: pageSize);
  }
}
