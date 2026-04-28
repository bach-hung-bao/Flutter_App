import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository _repository;
  const UpdateProfileUseCase(this._repository);

  Future<void> execute({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    String? dateOfBirth,
  }) {
    return _repository.updateProfile(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      dateOfBirth: dateOfBirth,
    );
  }
}
