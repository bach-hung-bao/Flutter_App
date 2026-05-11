import '../../../../../core/network/api_client.dart';
import '../../../../../core/storage/auth_storage.dart';
import '../../../domain/entities/review_entity.dart';
import '../../models/review_model.dart';
class ReviewRemoteDataSource {
  ReviewRemoteDataSource({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;
  final AuthStorage _authStorage = AuthStorage();

  Future<ReviewEntity> createReview({
    required int bookingId,
    required int roomId,
    required int rating,
    String? comment,
  }) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.post(
      '/api/reviews',
      accessToken: token,
      body: {
        'bookingId': bookingId,
        'roomId': roomId,
        'rating': rating,
        if (comment != null) 'comment': comment,
      },
    );
    return ReviewModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
