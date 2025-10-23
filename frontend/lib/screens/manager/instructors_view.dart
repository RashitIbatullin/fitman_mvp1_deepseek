import 'package:fitman_app/models/user_front.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для получения всех инструкторов, назначенных менеджеру
final assignedInstructorsProvider = FutureProvider<List<User>>((ref) async {
  // TODO: Implement ApiService.getAssignedInstructors
  return ApiService.getAssignedInstructors();
});

class InstructorsView extends ConsumerWidget {
  const InstructorsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorsAsyncValue = ref.watch(assignedInstructorsProvider);

    return instructorsAsyncValue.when(
      data: (instructors) {
        if (instructors.isEmpty) {
          return const Center(child: Text('Нет назначенных инструкторов.'));
        }
        return ListView.builder(
          itemCount: instructors.length,
          itemBuilder: (context, index) {
            final instructor = instructors[index];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(instructor.fullName),
              subtitle: Text(instructor.email),
              onTap: () {
                // TODO: Implement navigation to instructor details
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Ошибка загрузки инструкторов: $error')),
    );
  }
}
