import '../entities/hotel_entity.dart';
import '../repositories/hotel_repository.dart';

class GetHotelByIdUseCase {
  final HotelRepository _repository;
  const GetHotelByIdUseCase(this._repository);

  Future<HotelEntity?> execute(int id) => _repository.getById(id);
}
