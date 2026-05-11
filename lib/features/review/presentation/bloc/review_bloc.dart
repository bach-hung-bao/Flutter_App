import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_review_usecase.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final CreateReviewUseCase createReview;

  ReviewBloc({required this.createReview}) : super(ReviewInitial()) {
    on<CreateReviewEvent>(_onCreateReview);
  }

  Future<void> _onCreateReview(
      CreateReviewEvent event, Emitter<ReviewState> emit) async {
    emit(ReviewSubmitting());
    try {
      await createReview.execute(
        bookingId: event.bookingId,
        roomId: event.roomId,
        rating: event.rating,
        comment: event.comment,
      );
      emit(ReviewSuccess());
    } catch (e) {
      emit(ReviewFailure(e.toString()));
    }
  }
}
