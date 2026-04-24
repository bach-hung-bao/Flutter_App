import '../entities/auth_entity.dart';

/// Abstract repository – domain layer stays pure (no http/storage deps)
abstract class AuthRepository {
  Future<AuthEntity> login({required String email, required String password});

  Future<AuthEntity> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String role = 'Customer',
  });
}
