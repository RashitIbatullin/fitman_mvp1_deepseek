import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';

class UnknownRoleScreen extends ConsumerWidget {
  const UnknownRoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Неизвестная роль',
        showLogout: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'Неизвестная роль пользователя',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (user != null) ...[
                Text(
                  'Пользователь: ${user.email}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Роль: ${user.role}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Обратитесь к администратору для настройки прав доступа',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}