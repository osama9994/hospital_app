import 'dart:convert';
import 'package:hospital_app/features/auth/domain/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../../../core/network/api_endpoints.dart';


class AuthRepository {
  final http.Client _client;

  AuthRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['token'];
        final userData = data['user'];

        final user = UserModel.fromJson(userData, token: token);

        // حفظ بيانات الجلسة محلياً عبر Hive
        final authBox = Hive.box('authBox');
        await authBox.put('token', token);
        await authBox.put('user', user.toJson());

        return user;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'فشل تسجيل الدخول');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالسيرفر: $e');
    }
  }

  // التحقق مما إذا كان المستخدم مسجلاً لدخوله سابقاً عند فتح التطبيق
  UserModel? getSavedUser() {
    final authBox = Hive.box('authBox');
    final userData = authBox.get('user');
    final token = authBox.get('token');

    if (userData != null && token != null) {
      return UserModel.fromJson(Map<String, dynamic>.from(userData), token: token);
    }
    return null;
  }

  // تسجيل الخروج ومسح بيانات الجلسة
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
  final response = await _client.post(
    Uri.parse('${ApiEndpoints.baseUrl}/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'hospital_id': hospitalId,
      'role': role,
    }),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final user = UserModel.fromJson(data['user']);
    
    // Save session locally using Hive
    final box = Hive.box('authBox');
    await box.put('user', user.toJson());
    await box.put('token', data['token']);
    
    return user;
  } else {
    final errorData = jsonDecode(response.body);
    throw Exception(errorData['message'] ?? 'Failed to register account');
  }
}

}