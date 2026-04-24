import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.bookingId,
    required super.customerId,
    required super.roomId,
    required super.rating,
    super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id:         (json['id'] as num).toInt(),
      bookingId:  (json['bookingId'] as num?)?.toInt() ?? 0,
      customerId: (json['customerId'] as num?)?.toInt() ?? 0,
      roomId:     (json['roomId'] as num?)?.toInt() ?? 0,
      rating:     (json['rating'] as num?)?.toInt() ?? 5,
      comment:    json['comment'] as String?,
      createdAt:  DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
