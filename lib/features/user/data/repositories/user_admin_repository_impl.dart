import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_admin_repository.dart';
import '../datasources/remote/user_remote_data_source.dart';

class UserAdminRepositoryImpl implements UserAdminRepository {
  final UserRemoteDataSource remoteDataSource;

  UserAdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<(List<UserEntity>, int)> getUsers({int pageIndex = 1, int pageSize = 20}) async {
    return await remoteDataSource.getUsers(pageIndex: pageIndex, pageSize: pageSize);
  }

  @override
  Future<UserEntity?> getUserById(int id) async {
    return await remoteDataSource.getUserById(id);
  }

  @override
  Future<UserEntity?> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String? avatarUrl,
  }) async {
    return await remoteDataSource.createUser(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<UserEntity?> updateUser({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    required int status,
    String? avatarUrl,
  }) async {
    return await remoteDataSource.updateUser(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      status: status,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<void> deleteUser(int id) async {
    return await remoteDataSource.deleteUser(id);
  }
}
