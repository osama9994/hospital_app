import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/auth/presentation/auth_provider.dart';


class PatientDashboard extends ConsumerWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          )
        ],
      ),
      body: const Center(
        child: Text("Viewing doctors, appointments, and medical prescriptions"),
      ),
    );
  }
}