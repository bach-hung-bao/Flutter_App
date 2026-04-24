import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/models/auth_session_model.dart';

export '../../features/auth/data/models/auth_session_model.dart';

class AuthStorage {
  static const _accessTokenKey = 'auth.accessToken';
  static const _refreshTokenKey = 'auth.refreshToken';
  static const _sessionKey = 'auth.session';

  Future<void> saveSession(AuthSessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, session.accessToken);
    await prefs.setString(_refreshTokenKey, session.refreshToken);
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<AuthSessionModel?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    return AuthSessionModel.fromJson(decoded);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_sessionKey);
  }
}
