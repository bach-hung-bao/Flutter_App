class TimeSlotEntity {
  final int id;
  final int roomId;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final bool isActive;

  const TimeSlotEntity({
    required this.id,
    required this.roomId,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.isActive,
  });
}
