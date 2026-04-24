import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class CreateReviewUseCase {
  final ReviewRepository _repository;
  const CreateReviewUseCase(this._repository);

  Future<ReviewEntity> execute({
    required int bookingId,
    required int roomId,
    required int rating,
    String? comment,
  }) {
    return _repository.createReview(
      bookingId: bookingId,
      roomId: roomId,
      rating: rating,
      comment: comment,
    );
  }
}
