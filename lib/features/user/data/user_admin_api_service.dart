import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_storage.dart';
import 'models/user_model.dart';
import '../domain/entities/user_entity.dart';

class UserAdminApiService {
  final ApiClient _client;
  final AuthStorage _authStorage = AuthStorage();

  UserAdminApiService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<(List<UserEntity>, int)> getUsers({
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.get(
      '/api/users',
      query: {'pageIndex': pageIndex, 'pageSize': pageSize},
      accessToken: token,
    );

    final data = response['data'];
    if (data is! List) return (<UserEntity>[], 0);
    final total = (response['totalCount'] as num?)?.toInt() ?? 0;
    final items = data
        .whereType<Map<String, dynamic>>()
        .map(UserModel.fromJson)
        .toList();
    return (items, total);
  }

  Future<UserEntity?> getUserById(int id) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.get('/api/users/$id', accessToken: token);
    final data = response['data'];
    if (data is! Map<String, dynamic>) return null;
    return UserModel.fromJson(data);
  }

  Future<UserEntity?> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String? avatarUrl,
  }) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.post(
      '/api/users',
      accessToken: token,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        if (avatarUrl != null && avatarUrl.trim().isNotEmpty)
          'avatarUrl': avatarUrl,
      },
    );

    final data = response['data'];
    if (data is! Map<String, dynamic>) return null;
    return UserModel.fromJson(data);
  }

  Future<UserEntity?> updateUser({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    required int status,
    String? avatarUrl,
  }) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.put(
      '/api/users/$id',
      accessToken: token,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'status': status,
        if (avatarUrl != null && avatarUrl.trim().isNotEmpty)
          'avatarUrl': avatarUrl,
      },
    );

    final data = response['data'];
    if (data is! Map<String, dynamic>) return null;
    return UserModel.fromJson(data);
  }

  Future<void> deleteUser(int id) async {
    final token = await _authStorage.getAccessToken();
    await _client.delete('/api/users/$id', accessToken: token);
  }
}
