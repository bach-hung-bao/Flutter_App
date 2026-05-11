import '../../domain/entities/hotel_recommendation_entity.dart';

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
      // Map linh hoạt: ưu tiên hotelId, nếu không có thì lấy id
      hotelId:
          (json['hotelId'] as num?)?.toInt() ??
          (json['id'] as num?)?.toInt() ??
          0,
      name: (json['name'] as String?) ?? 'Khách sạn',
      // Map ảnh từ nhiều nguồn (imageUrl hoặc image1 từ script SQL)
      imageUrl:
          json['imageUrl'] as String? ??
          json['image1'] as String? ??
          json['thumbnail'] as String?,
      province: json['province'] as String? ?? json['provinceName'] as String?,
      ward: json['ward'] as String? ?? json['wardName'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 5.0,
      roomCount: (json['roomCount'] as num?)?.toInt() ?? 0,
      bookingCount: (json['bookingCount'] as num?)?.toInt() ?? 0,
      // Lấy giá từ avgRoomPrice hoặc standardPrice trong database
      avgRoomPrice:
          (json['avgRoomPrice'] as num?)?.toDouble() ??
          (json['standardPrice'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble(),
      score:
          (json['similarityScore'] as num?)?.toDouble() ??
          (json['score'] as num?)?.toDouble() ??
          0.0,
    );
  }
}
