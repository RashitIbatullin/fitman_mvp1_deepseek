import 'package:fitman_app/models/user_front.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для получения тренеров для конкретного инструктора
final assignedTrainersProvider = FutureProvider.family<List<User>, int>((ref, instructorId) async {
  return ApiService.getAssignedTrainersForInstructor(instructorId);
});

class MyTrainerView extends ConsumerWidget {
  final int instructorId;
  const MyTrainerView({super.key, required this.instructorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainersAsyncValue = ref.watch(assignedTrainersProvider(instructorId));

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
