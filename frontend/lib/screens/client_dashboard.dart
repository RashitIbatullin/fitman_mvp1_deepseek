import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';

class ClientDashboardScreen extends ConsumerWidget {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: CustomAppBar.client(
        title: 'Добро пожаловать, ${user?.firstName ?? 'Клиент'}!',
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Навигация к уведомлениям
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Панель клиента',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Здесь будут ваши тренировки и прогресс'),
          ],
        ),
      ),
    );
  }
}