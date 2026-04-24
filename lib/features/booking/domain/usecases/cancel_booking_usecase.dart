import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class CancelBookingUseCase {
  final BookingRepository _repository;
  const CancelBookingUseCase(this._repository);

  Future<BookingEntity?> execute(int bookingId, String reason) {
    return _repository.cancelBooking(bookingId, reason);
  }
}
