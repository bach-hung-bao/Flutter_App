import '../entities/time_slot_entity.dart';
import '../repositories/booking_repository.dart';

class GetTimeSlotsByRoomIdUseCase {
  final BookingRepository repository;

  GetTimeSlotsByRoomIdUseCase(this.repository);

  Future<List<TimeSlotEntity>> execute(int roomId) {
    return repository.getTimeSlotsByRoom(roomId);
  }
}
