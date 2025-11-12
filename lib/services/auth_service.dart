// dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class AuthService {
  static const _tokenKey = 'token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    final uri = ApiConfig.uri(ApiEndpoints.login); // 👈 usa el config
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await _storage.write(key: _tokenKey, value: token);
        return true;
      }
    }
    return false;
  }

  Future<bool> checkToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return false;
    final uri = ApiConfig.uri(ApiEndpoints.checkToken);
    final resp = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
    return resp.statusCode == 200;
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }
}