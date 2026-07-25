import 'package:flutter/material.dart';
import 'package:hospital_app/features/auth/presentation/admin_dashboard.dart';
import 'package:hospital_app/features/auth/presentation/doctor_dashboard.dart';
import 'package:hospital_app/features/auth/presentation/patient_dashboard.dart';
import 'package:hospital_app/features/auth/presentation/reception_dashboard.dart';
import '../domain/user_model.dart';

// role_router.dart
class RoleRouter extends StatelessWidget {
  final UserModel user;

  const RoleRouter({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    switch (user.role.toLowerCase()) {
      case 'admin':
        return const AdminDashboard();
      case 'doctor':
        return const DoctorDashboard();
      case 'receptionist':
        return const ReceptionDashboard();
      case 'patient':
        return const PatientDashboard();
      default:
        return const Scaffold(
          body: Center(
            child: Text('Unknown User Role!'),
          ),
        );
    }
  }
}