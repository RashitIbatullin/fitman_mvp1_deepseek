import 'package:fitman_app/models/user_front.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin/assign_clients_screen.dart';

// Провайдер для получения всех клиентов, назначенных менеджеру
final assignedClientsProvider = FutureProvider<List<User>>((ref) async {
  // Здесь мы предполагаем, что ApiService может получить клиентов для текущего менеджера
  // В реальном приложении может потребоваться передать ID менеджера
  return ApiService.getAssignedClients();
});

class ClientsView extends ConsumerWidget {
  const ClientsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsyncValue = ref.watch(assignedClientsProvider);

    return clientsAsyncValue.when(
      data: (clients) {
        if (clients.isEmpty) {
          return const Center(child: Text('Нет назначенных клиентов.'));
        }
        return ListView.builder(
          itemCount: clients.length,
          itemBuilder: (context, index) {
            final client = clients[index];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(client.fullName),
              subtitle: Text(client.email),
              onTap: () {
                // TODO: Implement navigation to client details
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Ошибка загрузки клиентов: $error')),
    );
  }
}
