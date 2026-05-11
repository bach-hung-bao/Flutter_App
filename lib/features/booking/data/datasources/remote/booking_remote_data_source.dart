import '../../../../../core/network/api_client.dart';
import '../../../../../core/storage/auth_storage.dart';
import '../../../domain/entities/booking_entity.dart';

import '../../models/booking_model.dart';
import '../../models/room_model.dart';
import '../../models/time_slot_model.dart';

class BookingRemoteDataSource {
  BookingRemoteDataSource({ApiClient? client})
    : _client = client ?? ApiClient();

  final ApiClient _client;
  final AuthStorage _authStorage = AuthStorage();

  Future<BookingEntity> createRequest({
    required int roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guestCount,
    required double paidAmount,
    String? paymentMethod,
    String? transactionCode,
    String? paymentNote,
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
        if (transactionCode != null && transactionCode.trim().isNotEmpty)
          'transactionCode': transactionCode.trim(),
        if (paymentNote != null && paymentNote.trim().isNotEmpty)
          'paymentNote': paymentNote.trim(),
        if (note != null) 'note': note,
      },
    );
    return BookingModel.fromJson(response['data'] as Map<String, dynamic>);
  }

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

  Future<List<RoomModel>> getRoomsByHotel(int hotelId) async {
    final response = await _client.get(
      '/api/rooms/by-hotel',
      query: {'hotelId': hotelId},
    );
    final data = response['data'] ?? response;
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(RoomModel.fromJson)
        .where((room) => room.isAvailable)
        .toList();
  }

  Future<List<TimeSlotModel>> getTimeSlotsByRoom(int roomId) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.get(
      '/api/time-slots/room/$roomId',
      accessToken: token,
    );
    final data = response['data'] ?? response;
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(TimeSlotModel.fromJson)
        .toList();
  }
}
