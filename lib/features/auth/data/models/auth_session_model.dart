import '../../domain/entities/auth_entity.dart';

/// Data-layer model: extends AuthEntity, adds JSON serialisation
class AuthSessionModel extends AuthEntity {
  const AuthSessionModel({
    required super.userId,
    required super.fullName,
    required super.email,
    required super.roles,
    required super.accessToken,
    required super.refreshToken,
    required super.accessTokenExpiresAt,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    DateTime? expiresAt;
    final rawExpires = json['accessTokenExpiresAt'];
    if (rawExpires is String && rawExpires.isNotEmpty) {
      expiresAt = DateTime.tryParse(rawExpires);
    }

    final rawRoles = json['roles'];
    final roles = rawRoles is List
        ? rawRoles.whereType<String>().toList()
        : <String>[];

    return AuthSessionModel(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      fullName: (json['fullName'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      roles: roles,
      accessToken: (json['accessToken'] as String?) ?? '',
      refreshToken: (json['refreshToken'] as String?) ?? '',
      accessTokenExpiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'fullName': fullName,
        'email': email,
        'roles': roles,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'accessTokenExpiresAt': accessTokenExpiresAt?.toIso8601String(),
      };
}

// Backward-compat alias so existing code referencing AuthSession still compiles
typedef AuthSession = AuthSessionModel;
