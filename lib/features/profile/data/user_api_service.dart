import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_storage.dart';

class UserApiService {
  final ApiClient _client;
  final AuthStorage _authStorage = AuthStorage();

  UserApiService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<void> updateProfile({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    String? dateOfBirth,
  }) async {
    final token = await _authStorage.getAccessToken();
    await _client.put(
      '/api/users/$id',
      accessToken: token,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phone,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      },
    );
  }
}
