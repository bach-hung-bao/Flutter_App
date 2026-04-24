/// Pure entity – no JSON, no fromJson
class HotelRecommendationEntity {
  final int hotelId;
  final String name;
  final String? imageUrl;
  final String? province;
  final String? ward;
  final double? averageRating;
  final int roomCount;
  final int bookingCount;
  final double? avgRoomPrice;
  final double score;

  const HotelRecommendationEntity({
    required this.hotelId,
    required this.name,
    this.imageUrl,
    this.province,
    this.ward,
    this.averageRating,
    required this.roomCount,
    required this.bookingCount,
    this.avgRoomPrice,
    required this.score,
  });
}
