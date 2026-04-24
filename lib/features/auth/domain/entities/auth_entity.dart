/// Pure domain entity – no JSON, no Flutter deps
class AuthEntity {
  final int userId;
  final String fullName;
  final String email;
  final List<String> roles;
  final String accessToken;
  final String refreshToken;
  final DateTime? accessTokenExpiresAt;

  const AuthEntity({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.roles,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
  });

  bool get isCustomer  => roles.contains('Customer');
  bool get isOwner     => roles.contains('Owner');
  bool get isAdmin     => roles.contains('Admin');
}
