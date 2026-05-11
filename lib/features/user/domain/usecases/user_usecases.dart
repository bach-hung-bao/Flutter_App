import '../entities/user_entity.dart';
import '../repositories/user_admin_repository.dart';

class GetUsersUseCase {
  final UserAdminRepository repository;
  GetUsersUseCase(this.repository);

  Future<(List<UserEntity>, int)> execute({int pageIndex = 1, int pageSize = 20}) {
    return repository.getUsers(pageIndex: pageIndex, pageSize: pageSize);
  }
}

class GetUserByIdUseCase {
  final UserAdminRepository repository;
  GetUserByIdUseCase(this.repository);

  Future<UserEntity?> execute(int id) {
    return repository.getUserById(id);
  }
}

class CreateUserUseCase {
  final UserAdminRepository repository;
  CreateUserUseCase(this.repository);

  Future<UserEntity?> execute({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String? avatarUrl,
  }) {
    return repository.createUser(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
      avatarUrl: avatarUrl,
    );
  }
}

class UpdateUserUseCase {
  final UserAdminRepository repository;
  UpdateUserUseCase(this.repository);

  Future<UserEntity?> execute({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    required int status,
    String? avatarUrl,
  }) {
    return repository.updateUser(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      status: status,
      avatarUrl: avatarUrl,
    );
  }
}

class DeleteUserUseCase {
  final UserAdminRepository repository;
  DeleteUserUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deleteUser(id);
  }
}
