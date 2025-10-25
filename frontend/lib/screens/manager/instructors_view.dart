import 'package:fitman_app/models/user_front.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для получения инструкторов для конкретного менеджера
final assignedInstructorsProvider = FutureProvider.family<List<User>, int>((ref, managerId) async {
  return ApiService.getAssignedInstructors(managerId);
});

class InstructorsView extends ConsumerWidget {
  final int managerId;
  const InstructorsView({super.key, required this.managerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorsAsyncValue = ref.watch(assignedInstructorsProvider(managerId));

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
