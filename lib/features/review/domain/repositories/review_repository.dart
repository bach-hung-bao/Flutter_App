import '../entities/review_entity.dart';

abstract class ReviewRepository {
  Future<ReviewEntity> createReview({
    required int bookingId,
    required int roomId,
    required int rating,
    String? comment,
  });
}
