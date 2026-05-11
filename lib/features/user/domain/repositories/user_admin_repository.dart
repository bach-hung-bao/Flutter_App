import '../entities/user_entity.dart';

abstract class UserAdminRepository {
  Future<(List<UserEntity>, int)> getUsers({int pageIndex = 1, int pageSize = 20});
  Future<UserEntity?> getUserById(int id);
  Future<UserEntity?> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String? avatarUrl,
  });
  Future<UserEntity?> updateUser({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    required int status,
    String? avatarUrl,
  });
  Future<void> deleteUser(int id);
}
