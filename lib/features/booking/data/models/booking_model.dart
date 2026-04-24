import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.roomId,
    required super.customerId,
    required super.checkInDate,
    required super.checkOutDate,
    required super.nightCount,
    required super.guestCount,
    required super.roomUnitPrice,
    required super.totalAmount,
    super.note,
    required super.status,
    super.cancelReason,
    super.cancelledAt,
    required super.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id:            (json['id'] as num).toInt(),
      roomId:        (json['roomId'] as num?)?.toInt() ?? 0,
      customerId:    (json['customerId'] as num?)?.toInt() ?? 0,
      checkInDate:   DateTime.tryParse(json['checkInDate'] as String? ?? '') ?? DateTime.now(),
      checkOutDate:  DateTime.tryParse(json['checkOutDate'] as String? ?? '') ?? DateTime.now(),
      nightCount:    (json['nightCount'] as num?)?.toInt() ?? 0,
      guestCount:    (json['guestCount'] as num?)?.toInt() ?? 1,
      roomUnitPrice: (json['roomUnitPrice'] as num?)?.toDouble() ?? 0,
      totalAmount:   (json['totalAmount'] as num?)?.toDouble() ?? 0,
      note:          json['note'] as String?,
      status:        (json['status'] as num?)?.toInt() ?? 0,
      cancelReason:  json['cancelReason'] as String?,
      cancelledAt:   json['cancelledAt'] != null
                       ? DateTime.tryParse(json['cancelledAt'] as String)
                       : null,
      createdAt:     DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
