import 'package:fitman_app/models/schedule_item.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Провайдер для получения расписания
final scheduleProvider = FutureProvider<List<ScheduleItem>>((ref) async {
  return ApiService.getSchedule();
});

class ScheduleView extends ConsumerWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsyncValue = ref.watch(scheduleProvider);

    return scheduleAsyncValue.when(
      data: (schedule) {
        if (schedule.isEmpty) {
          return const Center(child: Text('В расписании пока ничего нет.'));
        }
        return ListView.builder(
          itemCount: schedule.length,
          itemBuilder: (context, index) {
            final item = schedule[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text((index + 1).toString()),
                ),
                title: Text(item.trainingPlanName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Тренер: ${item.trainerName}'),
                    Text(
                      'Время: ${DateFormat.yMd().add_Hm().format(item.startTime)} - ${DateFormat.Hm().format(item.endTime)}',
                    ),
                  ],
                ),
                trailing: Chip(label: Text(item.status)),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Ошибка загрузки расписания: $error')),
    );
  }
}
