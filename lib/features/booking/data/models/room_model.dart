import '../../domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.hotelId,
    required super.roomTypeId,
    super.roomNumber,
    required super.capacity,
    required super.price,
    required super.status,
    required super.isDeleted,
    required super.createdAt,
    super.hotelName,
    super.roomTypeName,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: (json['id'] as num).toInt(),
      hotelId: (json['hotelId'] as num).toInt(),
      roomTypeId: (json['roomTypeId'] as num).toInt(),
      roomNumber: json['roomNumber'] as String?,
      capacity: (json['capacity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      status: (json['status'] as num).toInt(),
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      hotelName: json['hotelName'] as String?,
      roomTypeName: json['roomTypeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotelId': hotelId,
      'roomTypeId': roomTypeId,
      'roomNumber': roomNumber,
      'capacity': capacity,
      'price': price,
      'status': status,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      if (hotelName != null) 'hotelName': hotelName,
      if (roomTypeName != null) 'roomTypeName': roomTypeName,
    };
  }
}
