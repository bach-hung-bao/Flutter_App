abstract class ProfileRepository {
  Future<void> updateProfile({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    String? dateOfBirth,
  });

  Future<void> updateAvatar({
    required List<int> bytes,
    required String fileName,
  });

  Future<void> addFcmToken(String tokenValue);
}
