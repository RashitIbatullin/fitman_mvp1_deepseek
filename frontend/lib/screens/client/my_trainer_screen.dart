import 'package:fitman_app/models/user_front.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final trainerProvider = FutureProvider<User>((ref) async {
  return ApiService.getTrainerForClient();
});

class MyTrainerScreen extends ConsumerWidget {
  const MyTrainerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainerData = ref.watch(trainerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой тренер'),
      ),
      body: trainerData.when(
        data: (trainer) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    // backgroundImage: NetworkImage(trainer.photoUrl), // TODO: Add photo URL
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trainer.fullName, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(trainer.phone ?? '', style: Theme.of(context).textTheme.titleMedium),
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
                        Text('Чат с тренером', style: Theme.of(context).textTheme.titleLarge),
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
