import 'package:fitman_app/models/user_front.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для получения всех тренеров, назначенных инструктору
final assignedTrainersProvider = FutureProvider<List<User>>((ref) async {
  return ApiService.getAssignedTrainersForInstructor();
});

class MyTrainerView extends ConsumerWidget {
  const MyTrainerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainersAsyncValue = ref.watch(assignedTrainersProvider);

    return trainersAsyncValue.when(
      data: (trainers) {
        if (trainers.isEmpty) {
          return const Center(child: Text('Нет назначенных тренеров.'));
        }
        return ListView.builder(
          itemCount: trainers.length,
          itemBuilder: (context, index) {
            final trainer = trainers[index];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(trainer.fullName),
              subtitle: Text(trainer.email),
              onTap: () {
                // TODO: Implement navigation to trainer details
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Ошибка загрузки тренеров: $error')),
    );
  }
}
