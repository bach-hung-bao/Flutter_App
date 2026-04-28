abstract class ProfileRepository {
  Future<void> updateProfile({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    String? dateOfBirth,
  });
}
