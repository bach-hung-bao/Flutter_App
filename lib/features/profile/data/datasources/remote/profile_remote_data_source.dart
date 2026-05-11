import 'package:http/http.dart' as http;
import '../../../../../core/network/api_client.dart';
import '../../../../../core/storage/auth_storage.dart';

class ProfileRemoteDataSource {
  final ApiClient _client;
  final AuthStorage _authStorage = AuthStorage();

  ProfileRemoteDataSource({ApiClient? client})
    : _client = client ?? ApiClient();

  Future<void> updateProfile({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    String? dateOfBirth,
  }) async {
    final token = await _authStorage.getAccessToken();

    // Đã đưa lại về đúng chữ 'body:' như code gốc của bạn
    await _client.put(
      '/api/users/$id',
      accessToken: token,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      },
    );
  }

  Future<void> updateAvatar({
    required List<int> bytes,
    required String fileName,
  }) async {
    final token = await _authStorage.getAccessToken();
    final file = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fileName,
    );
    await _client.postMultipart(
      '/api/users/me/avatar',
      accessToken: token,
      files: [file],
    );
  }

  Future<void> addFcmToken(String tokenValue) async {
    final token = await _authStorage.getAccessToken();
    await _client.post(
      '/api/users/fcm-token',
      accessToken: token,
      body: {'token': tokenValue},
    );
  }
}
