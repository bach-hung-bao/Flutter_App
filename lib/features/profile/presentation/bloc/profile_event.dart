abstract class ProfileEvent {
  const ProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final int userId;
  final String firstName;
  final String lastName;
  final String phone;
  final String? dateOfBirth;

  const UpdateProfileEvent({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.dateOfBirth,
  });
}
