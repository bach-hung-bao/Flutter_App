import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class UpdateBookingStatusUseCase {
  final BookingRepository repository;

  UpdateBookingStatusUseCase(this.repository);

  Future<BookingEntity?> execute(int id, int status) async {
    return await repository.updateBookingStatus(id, status);
  }
}
