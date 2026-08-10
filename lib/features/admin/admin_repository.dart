import 'dart:convert';
import 'package:hospital_app/features/admin/domain/department_model.dart';
import 'package:hospital_app/features/admin/domain/doctor_model.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../../../../core/network/api_endpoints.dart';


class AdminRepository {
  final http.Client _client;

  AdminRepository({http.Client? client}) : _client = client ?? http.Client();

  String? get _token {
    final box = Hive.box('authBox');
    return box.get('token');
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // --- Departments ---

  Future<List<DepartmentModel>> getDepartments() async {
    final response = await _client.get(
      Uri.parse('${ApiEndpoints.baseUrl}/admin/departments'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => DepartmentModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch departments');
    }
  }

  Future<DepartmentModel> createDepartment(String name, String description) async {
    final response = await _client.post(
      Uri.parse('${ApiEndpoints.baseUrl}/admin/departments'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return DepartmentModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create department');
    }
  }

  // --- Doctors ---

  Future<List<DoctorModel>> getDoctors() async {
    final response = await _client.get(
      Uri.parse('${ApiEndpoints.baseUrl}/admin/doctors'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => DoctorModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch doctors');
    }
  }

  Future<DoctorModel> createDoctor({
    required String name,
    required String email,
    required String password,
    required String specialization,
    required String departmentId,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiEndpoints.baseUrl}/admin/doctors'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'specialization': specialization,
        'department_id': departmentId,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return DoctorModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create doctor account');
    }
  }
}