import 'package:fitman_app/models/user_front.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final managerProvider = FutureProvider<User>((ref) async {
  return ApiService.getManagerForClient();
});

class MyManagerScreen extends ConsumerWidget {
  const MyManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final managerData = ref.watch(managerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой менеджер'),
      ),
      body: managerData.when(
        data: (manager) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    // backgroundImage: NetworkImage(manager.photoUrl), // TODO: Add photo URL
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(manager.fullName, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(manager.phone ?? '', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Чат с менеджером', style: Theme.of(context).textTheme.titleLarge),
                        const Expanded(
                          child: Center(
                            child: Text('Здесь будет чат'),
                          ),
                        ),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Введите сообщение...',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }
}
