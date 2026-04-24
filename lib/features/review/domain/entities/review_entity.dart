class ReviewEntity {
  final int id;
  final int bookingId;
  final int customerId;
  final int roomId;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.roomId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });
}
