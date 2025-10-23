import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Провайдер для получения данных расписания
final scheduleProvider = FutureProvider<List<dynamic>>((ref) async {
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
          return const Center(child: Text('Расписание пусто.'));
        }
        return ListView.builder(
          itemCount: schedule.length,
          itemBuilder: (context, index) {
            final item = schedule[index];
            final startTime = DateTime.parse(item['start_time']);
            final endTime = DateTime.parse(item['end_time']);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(item['training_plan_name'] ?? 'Без названия'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Тренер: ${item['trainer_name'] ?? 'Не назначен'}'),
                    Text(
                      '${DateFormat.yMMMd('ru_RU').add_Hm().format(startTime)} - ${DateFormat.Hm('ru_RU').format(endTime)}',
                    ),
                  ],
                ),
                trailing: Chip(
                  label: Text(item['status'] ?? 'Нет статуса'),
                ),
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