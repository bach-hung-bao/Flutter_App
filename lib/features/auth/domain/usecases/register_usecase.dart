import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<AuthEntity> execute({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) {
    return _repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
    );
  }
}
