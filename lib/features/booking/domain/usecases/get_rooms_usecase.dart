import '../entities/room_entity.dart';
import '../repositories/booking_repository.dart';

class GetRoomsByHotelIdUseCase {
  final BookingRepository repository;

  GetRoomsByHotelIdUseCase(this.repository);

  Future<List<RoomEntity>> execute(int hotelId) {
    return repository.getRoomsByHotel(hotelId);
  }
}
