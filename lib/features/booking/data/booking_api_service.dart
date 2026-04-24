import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_storage.dart';
import '../domain/entities/booking_entity.dart';
import '../domain/repositories/booking_repository.dart';
import 'models/booking_model.dart';

class BookingApiService implements BookingRepository {
  BookingApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;
  final AuthStorage _authStorage = AuthStorage();

  @override
  Future<BookingEntity> createRequest({
    required int roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guestCount,
    required double paidAmount,
    String? paymentMethod,
    String? note,
  }) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.post(
      '/api/bookings/request',
      accessToken: token,
      body: {
        'roomId': roomId,
        'checkInDate': checkInDate.toIso8601String(),
        'checkOutDate': checkOutDate.toIso8601String(),
        'guestCount': guestCount,
        'paidAmount': paidAmount,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (note != null) 'note': note,
      },
    );
    return BookingModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<(List<BookingEntity>, int)> getMyBookings({
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.get(
      '/api/bookings/my-bookings',
      query: {'pageIndex': pageIndex, 'pageSize': pageSize},
      accessToken: token,
    );
    final data = response['data'];
    if (data is! List) return (<BookingEntity>[], 0);
    final total = (response['totalCount'] as num?)?.toInt() ?? 0;
    final items = data
        .whereType<Map<String, dynamic>>()
        .map(BookingModel.fromJson)
        .toList();
    return (items, total);
  }

  @override
  Future<BookingEntity?> cancelBooking(int id, String reason) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.post(
      '/api/bookings/$id/cancel',
      accessToken: token,
      body: {'reason': reason},
    );
    final data = response['data'];
    if (data is! Map<String, dynamic>) return null;
    return BookingModel.fromJson(data);
  }
}
