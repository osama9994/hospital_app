import 'dart:async';
import 'dart:convert';
import 'package:hospital_app/features/auth/domain/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../../../core/network/api_endpoints.dart';

class AuthRepository {
  final http.Client _client;

  AuthRepository({http.Client? client}) : _client = client ?? http.Client();

  String _extractErrorMessage(Map<String, dynamic> errorData, String fallback) {
    final message = errorData['message'] ??
        errorData['error_description'] ??
        errorData['error'] ??
        (errorData['data'] is Map ? errorData['data']['message'] : null);
    return message?.toString() ?? fallback;
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.trim().isEmpty) {
      return {};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    throw const FormatException('Response body is not a JSON object');
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  String? _extractToken(Map<String, dynamic> data) {
    final dataMap = _asMap(data['data']);
    final session = _asMap(data['session']) ?? _asMap(dataMap?['session']);

    return data['token']?.toString() ??
        data['access_token']?.toString() ??
        dataMap?['token']?.toString() ??
        dataMap?['access_token']?.toString() ??
        session?['access_token']?.toString();
  }

  Map<String, dynamic>? _extractUserData(Map<String, dynamic> data) {
    final dataMap = _asMap(data['data']);
    final session = _asMap(data['session']) ?? _asMap(dataMap?['session']);

    return _asMap(data['user']) ??
        _asMap(dataMap?['user']) ??
        _asMap(data['profile']) ??
        _asMap(dataMap?['profile']) ??
        _asMap(session?['user']);
  }

  Future<UserModel> _saveAuthenticatedUser(
    Map<String, dynamic> data, {
    required String missingTokenMessage,
  }) async {
    final userData = _extractUserData(data);
    if (userData == null) {
      throw Exception('Invalid server response: missing user');
    }

    final token = _extractToken(data);
    if (token == null || token.isEmpty) {
      throw Exception(missingTokenMessage);
    }

    final user = UserModel.fromJson(userData, token: token);

    final authBox = Hive.box('authBox');
    await authBox.put('token', token);
    await authBox.put('user', user.toJson());

    return user;
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 20));

      final data = _decodeBody(response);

      if (response.statusCode == 200) {
        return _saveAuthenticatedUser(
          data,
          missingTokenMessage: 'Invalid server response: missing access token',
        );
      }

      throw Exception(_extractErrorMessage(data, 'Login failed'));
    } on FormatException {
      throw Exception('Invalid server response');
    } on TimeoutException {
      throw Exception('Server request timed out. Make sure your API is running.');
    } on http.ClientException catch (e) {
      throw Exception('Could not connect to server: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Could not connect to server: $e');
    }
  }

  UserModel? getSavedUser() {
    final authBox = Hive.box('authBox');
    final userData = authBox.get('user');
    final token = authBox.get('token');

    if (userData != null && token != null) {
      return UserModel.fromJson(
        Map<String, dynamic>.from(userData),
        token: token.toString(),
      );
    }
    return null;
  }

  Future<void> logout() async {
    final authBox = Hive.box('authBox');
    await authBox.clear();
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String hospitalId,
    String role = 'patient',
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiEndpoints.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'hospital_id': hospitalId,
          'hospitalId': hospitalId,
          'role': role,
        }),
      ).timeout(const Duration(seconds: 20));

      final data = _decodeBody(response);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _saveAuthenticatedUser(
          data,
          missingTokenMessage:
              'Account created, but no session was returned. Check email confirmation or sign in manually.',
        );
      }

      throw Exception(_extractErrorMessage(data, 'Failed to register account'));
    } on FormatException {
      throw Exception('Invalid server response');
    } on TimeoutException {
      throw Exception('Server request timed out. Make sure your API is running.');
    } on http.ClientException catch (e) {
      throw Exception('Could not connect to server: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Could not connect to server: $e');
    }
  }

Future<UserModel?> validateSession() async {
  final authBox = Hive.box('authBox');
  final token = authBox.get('token');
  if (token == null) return null;

  try {
    final response = await _client.get(
      Uri.parse(ApiEndpoints.profile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = _decodeBody(response);
      // Profile endpoint might return the user wrapped (data/user/profile)
      // or as the raw object itself — fall back to `data` directly.
      final userData = _extractUserData(data) ?? data;
      final user = UserModel.fromJson(userData, token: token.toString());
      await authBox.put('user', user.toJson());
      return user;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      // Token is genuinely invalid/expired — clear the local session.
      await authBox.clear();
      return null;
    }

    // Some other server error: don't punish the user, keep the cached session.
    return getSavedUser();
  } on TimeoutException {
    return getSavedUser();
  } on http.ClientException {
    return getSavedUser();
  } catch (_) {
    return getSavedUser();
  }
}

}
