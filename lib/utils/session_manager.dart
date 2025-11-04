import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SessionManager {
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
  }

  Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) {
      return false;
    }

    // In a real scenario, you would make the API call.
    // We will simulate it here for now.
    return await _mockTokenValidation(token);
  }

  // Mock function for token validation
  Future<bool> _mockTokenValidation(String token) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate a call to https://ras.webintegral.cl/api/token
    // For now, we'll just check if the token is not empty.
    // In a real implementation, you'd decode the response and check the user_id.
    if (token.isNotEmpty) {
      // Let's pretend the API returns a user_id
      await _storage.write(key: _userIdKey, value: 'mock_user_123');
      return true;
    } else {
      return false;
    }
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }
}
