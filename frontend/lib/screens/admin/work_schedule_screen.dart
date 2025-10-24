import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/work_schedule_provider.dart';
import '../../models/work_schedule.dart';

class WorkScheduleScreen extends ConsumerWidget {
  const WorkScheduleScreen({super.key});

  String _dayOfWeekToString(int day) {
    switch (day) {
      case 1:
        return 'Понедельник';
      case 2:
        return 'Вторник';
      case 3:
        return 'Среда';
      case 4:
        return 'Четверг';
      case 5:
        return 'Пятница';
      case 6:
        return 'Суббота';
      case 7:
        return 'Воскресенье';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workSchedules = ref.watch(workScheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание работы центра'),
      ),
      body: workSchedules.when(
        data: (schedules) => ListView.builder(
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(_dayOfWeekToString(schedule.dayOfWeek)),
                subtitle: Text('${schedule.startTime} - ${schedule.endTime}'),
                trailing: Switch(
                  value: !schedule.isDayOff,
                  onChanged: (value) {
                    final updatedSchedule = WorkSchedule(
                      id: schedule.id,
                      dayOfWeek: schedule.dayOfWeek,
                      startTime: schedule.startTime,
                      endTime: schedule.endTime,
                      isDayOff: !value,
                    );
                    ref.read(workScheduleProvider.notifier).updateWorkSchedule(updatedSchedule);
                  },
                ),
                onTap: () => _showEditDialog(context, ref, schedule),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, WorkSchedule schedule) {
    final startTimeController = TextEditingController(text: schedule.startTime);
    final endTimeController = TextEditingController(text: schedule.endTime);
    final formKey = GlobalKey<FormState>(); // Add a GlobalKey for the Form

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Редактировать ${ _dayOfWeekToString(schedule.dayOfWeek)}'),
        content: Form( // Wrap content in a Form widget
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField( // Use TextFormField for validation
                controller: startTimeController,
                decoration: const InputDecoration(labelText: 'Начало работы (ЧЧ:ММ)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите время начала работы';
                  }
                  final timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
                  if (!timeRegex.hasMatch(value)) {
                    return 'Неверный формат времени. Используйте ЧЧ:ММ';
                  }
                  return null;
                },
              ),
              TextFormField( // Use TextFormField for validation
                controller: endTimeController,
                decoration: const InputDecoration(labelText: 'Конец работы (ЧЧ:ММ)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите время окончания работы';
                  }
                  final timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
                  if (!timeRegex.hasMatch(value)) {
                    return 'Неверный формат времени. Используйте ЧЧ:ММ';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) { // Validate the form
                final updatedSchedule = WorkSchedule(
                  id: schedule.id,
                  dayOfWeek: schedule.dayOfWeek,
                  startTime: startTimeController.text,
                  endTime: endTimeController.text,
                  isDayOff: schedule.isDayOff,
                );
                ref.read(workScheduleProvider.notifier).updateWorkSchedule(updatedSchedule);
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}