import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/admin/admin_repository.dart';
import 'package:hospital_app/features/admin/domain/department_model.dart';
import 'package:hospital_app/features/admin/domain/doctor_model.dart';


final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

// FutureProvider للحصول على الأقسام تلقائياً
final departmentsProvider = FutureProvider<List<DepartmentModel>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getDepartments();
});

// FutureProvider للحصول على الأطباء تلقائياً
final doctorsProvider = FutureProvider<List<DoctorModel>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getDoctors();
});