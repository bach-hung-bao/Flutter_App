class RoomEntity {
  final int id;
  final int hotelId;
  final int roomTypeId;
  final String? roomNumber;
  final int capacity;
  final double price;
  final int status;
  final bool isDeleted;
  final DateTime createdAt;
  final String? hotelName;
  final String? roomTypeName;

  bool get isAvailable => !isDeleted && status == 1;

  const RoomEntity({
    required this.id,
    required this.hotelId,
    required this.roomTypeId,
    this.roomNumber,
    required this.capacity,
    required this.price,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
    this.hotelName,
    this.roomTypeName,
  });
}
