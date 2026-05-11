import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/entities/time_slot_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/remote/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BookingEntity> createRequest({
    required int roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guestCount,
    required double paidAmount,
    String? paymentMethod,
    String? transactionCode,
    String? paymentNote,
    String? note,
  }) async {
    return await remoteDataSource.createRequest(
      roomId: roomId,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      guestCount: guestCount,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
      transactionCode: transactionCode,
      paymentNote: paymentNote,
      note: note,
    );
  }

  @override
  Future<(List<BookingEntity>, int)> getMyBookings({
    int pageIndex = 1,
    int pageSize = 20,
    String? status, // Not supported by remote data source currently
  }) async {
    return await remoteDataSource.getMyBookings(
      pageIndex: pageIndex,
      pageSize: pageSize,
    );
  }

  @override
  Future<BookingEntity?> cancelBooking(int id, String reason) async {
    return await remoteDataSource.cancelBooking(id, reason);
  }

  @override
  Future<List<RoomEntity>> getRoomsByHotel(int hotelId) {
    return remoteDataSource.getRoomsByHotel(hotelId);
  }

  @override
  Future<List<TimeSlotEntity>> getTimeSlotsByRoom(int roomId) {
    return remoteDataSource.getTimeSlotsByRoom(roomId);
  }
}
