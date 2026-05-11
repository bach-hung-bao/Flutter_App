abstract class ReviewEvent {
  const ReviewEvent();
}

class CreateReviewEvent extends ReviewEvent {
  final int bookingId;
  final int roomId;
  final int rating;
  final String? comment;

  const CreateReviewEvent({
    required this.bookingId,
    required this.roomId,
    required this.rating,
    this.comment,
  });
}
