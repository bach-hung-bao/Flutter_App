import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetMyBookingsUseCase {
  final BookingRepository _repository;
  const GetMyBookingsUseCase(this._repository);

  Future<(List<BookingEntity>, int)> execute({
    int pageIndex = 1,
    int pageSize = 20,
  }) {
    return _repository.getMyBookings(pageIndex: pageIndex, pageSize: pageSize);
  }
}
