import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hospital_app/features/auth/presentation/auth_provider.dart';

class DoctorDashboard extends ConsumerWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          )
        ],
      ),
      body: const Center(
        child: Text("Patient Appointment Schedule and Medical Records"),
      ),
    );
  }
}