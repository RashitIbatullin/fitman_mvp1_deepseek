import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: CustomAppBar.admin(
        title: 'Администратор: ${user?.firstName ?? ''}',
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: () {
              // Управление правами доступа
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 64, color: Colors.purple),
            SizedBox(height: 16),
            Text(
              'Панель администратора',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Управление системой и пользователями'),
          ],
        ),
      ),
    );
  }
}