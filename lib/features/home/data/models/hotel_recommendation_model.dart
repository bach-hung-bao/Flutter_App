import '../../domain/entities/hotel_recommendation_entity.dart';

/// Data model: extends entity, adds JSON parsing
class HotelRecommendationModel extends HotelRecommendationEntity {
  const HotelRecommendationModel({
    required super.hotelId,
    required super.name,
    super.imageUrl,
    super.province,
    super.ward,
    super.averageRating,
    required super.roomCount,
    required super.bookingCount,
    super.avgRoomPrice,
    required super.score,
  });

  factory HotelRecommendationModel.fromJson(Map<String, dynamic> json) {
    return HotelRecommendationModel(
      hotelId:      (json['hotelId'] as num?)?.toInt() ?? 0,
      name:         (json['name'] as String?) ?? 'Khách sạn',
      imageUrl:     json['imageUrl'] as String?,
      province:     json['province'] as String?,
      ward:         json['ward'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      roomCount:    (json['roomCount'] as num?)?.toInt() ?? 0,
      bookingCount: (json['bookingCount'] as num?)?.toInt() ?? 0,
      avgRoomPrice: (json['avgRoomPrice'] as num?)?.toDouble(),
      score:        (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
