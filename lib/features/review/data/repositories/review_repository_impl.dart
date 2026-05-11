import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/remote/review_remote_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ReviewEntity> createReview({
    required int bookingId,
    required int roomId,
    required int rating,
    String? comment,
  }) async {
    return await remoteDataSource.createReview(
      bookingId: bookingId,
      roomId: roomId,
      rating: rating,
      comment: comment,
    );
  }
}
