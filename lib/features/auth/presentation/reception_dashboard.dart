
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/auth/presentation/auth_provider.dart';


class ReceptionDashboard extends ConsumerWidget {
  const ReceptionDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reception Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          )
        ],
      ),
      body: const Center(
        child: Text("Booking appointments and confirming attendance"),
      ),
    );
  }
}