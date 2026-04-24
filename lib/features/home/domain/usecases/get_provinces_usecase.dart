import '../entities/province_entity.dart';
import '../repositories/home_repository.dart';

class GetProvincesUseCase {
  final HomeRepository _repository;
  const GetProvincesUseCase(this._repository);

  Future<List<ProvinceEntity>> execute({int pageSize = 8}) {
    return _repository.getProvinces(pageSize: pageSize);
  }
}
