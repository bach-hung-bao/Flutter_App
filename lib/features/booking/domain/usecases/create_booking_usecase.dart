import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository _repository;
  const CreateBookingUseCase(this._repository);

  Future<BookingEntity> execute({
    required int roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guestCount,
    required double paidAmount,
    String? paymentMethod,
    String? note,
  }) {
    return _repository.createRequest(
      roomId: roomId,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      guestCount: guestCount,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
      note: note,
    );
  }
}
