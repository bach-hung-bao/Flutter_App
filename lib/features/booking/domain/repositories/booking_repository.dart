import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<BookingEntity> createRequest({
    required int roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guestCount,
    required double paidAmount,
    String? paymentMethod,
    String? note,
  });

  Future<(List<BookingEntity>, int)> getMyBookings({
    int pageIndex = 1,
    int pageSize = 20,
  });

  Future<BookingEntity?> cancelBooking(int id, String reason);
}
