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

class UpdateAvatarUseCase {
  final ProfileRepository _repository;
  const UpdateAvatarUseCase(this._repository);

  Future<void> execute({required List<int> bytes, required String fileName}) {
    return _repository.updateAvatar(bytes: bytes, fileName: fileName);
  }
}

class AddFcmTokenUseCase {
  final ProfileRepository _repository;
  const AddFcmTokenUseCase(this._repository);

  Future<void> execute(String tokenValue) {
    return _repository.addFcmToken(tokenValue);
  }
}
