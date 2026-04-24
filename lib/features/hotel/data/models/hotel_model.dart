import '../../domain/entities/hotel_entity.dart';

class HotelModel extends HotelEntity {
  const HotelModel({
    required super.id,
    required super.ownerId,
    required super.wardId,
    required super.name,
    super.street,
    super.phone,
    super.description,
    required super.status,
    required super.createdAt,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id:          (json['id'] as num).toInt(),
      ownerId:     (json['ownerId'] as num?)?.toInt() ?? 0,
      wardId:      (json['wardId'] as num?)?.toInt() ?? 0,
      name:        (json['name'] as String?) ?? '',
      street:      json['street'] as String?,
      phone:       json['phone'] as String?,
      description: json['description'] as String?,
      status:      (json['status'] as num?)?.toInt() ?? 0,
      createdAt:   DateTime.tryParse(json['createdAt'] as String? ?? '') ??
                   DateTime.now(),
    );
  }
}
