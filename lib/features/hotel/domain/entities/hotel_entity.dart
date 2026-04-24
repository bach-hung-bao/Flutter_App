/// Pure domain entity for a Hotel – no JSON, no Flutter deps
class HotelEntity {
  final int id;
  final int ownerId;
  final int wardId;
  final String name;
  final String? street;
  final String? phone;
  final String? description;
  final int status; // 0=inactive, 1=active
  final DateTime createdAt;

  const HotelEntity({
    required this.id,
    required this.ownerId,
    required this.wardId,
    required this.name,
    this.street,
    this.phone,
    this.description,
    required this.status,
    required this.createdAt,
  });

  bool get isActive => status == 1;
}
