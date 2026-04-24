import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<AuthEntity> execute({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
