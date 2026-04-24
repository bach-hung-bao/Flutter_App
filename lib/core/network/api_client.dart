import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // ── GET ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    String? accessToken,
  }) async {
    final uri = _buildUri(path, query);
    final response = await _client.get(uri, headers: _headers(accessToken));
    return _handleResponse(response);
  }

  // ── POST ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    String? accessToken,
  }) async {
    final uri = _buildUri(path, query);
    final response = await _client.post(
      uri,
      headers: _headers(accessToken),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _handleResponse(response);
  }

  // ── PUT ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    final uri = _buildUri(path, null);
    final response = await _client.put(
      uri,
      headers: _headers(accessToken),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _handleResponse(response);
  }

  // ── DELETE ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> delete(
    String path, {
    String? accessToken,
  }) async {
    final uri = _buildUri(path, null);
    final response = await _client.delete(
      uri,
      headers: _headers(accessToken),
    );
    return _handleResponse(response);
  }

  // ── Helpers ─────────────────────────────────────────────────────
  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final raw = '${ApiConfig.baseUrl}$path';
    final uri = Uri.parse(raw);
    if (query == null || query.isEmpty) return uri;

    final queryParams = <String, String>{};
    for (final entry in query.entries) {
      if (entry.value != null) {
        queryParams[entry.key] = entry.value.toString();
      }
    }
    return uri.replace(queryParameters: queryParams);
  }

  Map<String, String> _headers(String? accessToken) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = _tryDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      return {'success': true, 'statusCode': response.statusCode, 'data': decoded};
    }
    final message = _extractMessage(decoded) ?? 'Yeu cau that bai';
    throw ApiException(message, response.statusCode);
  }

  dynamic _tryDecode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'];
      if (message is String && message.trim().isNotEmpty) return message;
      final errors = decoded['errors'];
      if (errors is List && errors.isNotEmpty) return errors.join(', ');
    }
    return null;
  }
}
