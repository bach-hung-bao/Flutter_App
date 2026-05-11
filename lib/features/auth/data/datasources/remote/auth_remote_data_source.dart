import '../../../../../core/network/api_client.dart';

import '../../../domain/entities/auth_entity.dart';
import '../../models/auth_session_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/api/auth/login',
      body: {'email': email.trim(), 'password': password},
    );
    return _parse(response);
  }

  Future<AuthSessionModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String role = 'Customer',
  }) async {
    final response = await _client.post(
      '/api/auth/register',
      body: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
        'role': role,
      },
    );
    return _parse(response);
  }

  Future<AuthSessionModel> refreshToken(String refreshToken) async {
    final response = await _client.post(
      '/api/auth/refresh-token',
      body: {'refreshToken': refreshToken},
    );
    return _parse(response);
  }

  AuthSessionModel _parse(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Du lieu auth khong hop le', 500);
    }
    return AuthSessionModel.fromJson(data);
  }
}
