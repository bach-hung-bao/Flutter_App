abstract class ReviewState {
  const ReviewState();
}

class ReviewInitial extends ReviewState {}

class ReviewSubmitting extends ReviewState {}

class ReviewSuccess extends ReviewState {}

class ReviewFailure extends ReviewState {
  final String message;

  const ReviewFailure(this.message);
}
