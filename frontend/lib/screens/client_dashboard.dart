import 'package:fitman_app/models/user_front.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';

class ClientDashboard extends ConsumerWidget {
  final User? client;

  const ClientDashboard({super.key, this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = client ?? ref.watch(authProvider).value;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Пользователь не найден')),
      );
    }

    return Scaffold(
      appBar: CustomAppBar.client(
        title: 'Профиль: ${user.firstName}',
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Навигация к уведомлениям
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Панель клиента: ${user.fullName}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Здесь будут тренировки и прогресс для ${user.email}'),
          ],
        ),
      ),
    );
  }
}