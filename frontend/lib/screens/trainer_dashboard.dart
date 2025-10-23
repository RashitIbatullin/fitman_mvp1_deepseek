import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';

class TrainerDashboard extends ConsumerWidget {
  const TrainerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: CustomAppBar.trainer(
        title: 'Тренер: ${user?.firstName ?? ''}',
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Создание новой тренировки
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Панель тренера',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Управление клиентами и тренировками'),
          ],
        ),
      ),
    );
  }
}