import 'package:fitman_app/models/user_front.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final instructorProvider = FutureProvider<User>((ref) async {
  return ApiService.getInstructorForClient();
});

class MyInstructorScreen extends ConsumerWidget {
  const MyInstructorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorData = ref.watch(instructorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой инструктор'),
      ),
      body: instructorData.when(
        data: (instructor) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    // backgroundImage: NetworkImage(instructor.photoUrl), // TODO: Add photo URL
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(instructor.fullName, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(instructor.phone ?? '', style: Theme.of(context).textTheme.titleMedium),
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
                        Text('Чат с инструктором', style: Theme.of(context).textTheme.titleLarge),
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
