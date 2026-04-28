class UserEntity {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final int status;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.status,
    this.avatarUrl,
    this.createdAt,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? '-' : name;
  }
}
