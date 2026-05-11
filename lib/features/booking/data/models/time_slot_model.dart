import '../../domain/entities/time_slot_entity.dart';

class TimeSlotModel extends TimeSlotEntity {
  const TimeSlotModel({
    required super.id,
    required super.roomId,
    required super.startDate,
    required super.endDate,
    required super.price,
    required super.isActive,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id: (json['id'] as num).toInt(),
      roomId: (json['roomId'] as num).toInt(),
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? '') ?? DateTime.now(),
      price: (json['price'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}
