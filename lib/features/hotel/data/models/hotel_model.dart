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
    required super.isDeleted,
    required super.createdAt,
    super.updatedAt,
    super.imageUrl, // 4. Truyền giá trị ảnh lên class cha
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: (json['id'] as num).toInt(),
      ownerId: (json['ownerId'] as num?)?.toInt() ?? 0,
      wardId: (json['wardId'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      street: json['street'] as String?,
      phone: json['phone'] as String?,
      description: json['description'] as String?,
      status: (json['status'] as num?)?.toInt() ?? 0,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      // 5. Đọc ảnh từ API, nếu không có thì dùng ảnh mặc định
      imageUrl: json['imageUrl'] as String? ?? 
                json['image'] as String? ?? 
                'https://images.unsplash.com/photo-1566073771259-6a8506099945',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'wardId': wardId,
      'name': name,
      'street': street,
      'phone': phone,
      'description': description,
      'status': status,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}