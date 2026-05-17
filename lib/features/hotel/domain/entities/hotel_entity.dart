class HotelEntity {
  final int id;
  final int ownerId;
  final int wardId;
  final String name;
  final String? street;
  final String? phone;
  final String? description;
  final int status;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? imageUrl; // ĐÃ THÊM BIẾN ẢNH VÀO ĐÂY

  const HotelEntity({
    required this.id,
    required this.ownerId,
    required this.wardId,
    required this.name,
    this.street,
    this.phone,
    this.description,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
    this.updatedAt,
    this.imageUrl, // ĐÃ THÊM VÀO CONSTRUCTOR
  });
}