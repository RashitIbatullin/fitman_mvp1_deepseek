import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/work_schedule_provider.dart';
import '../../models/work_schedule.dart';
import '../../services/api_service.dart'; // Import ApiService
import '../../models/client_schedule_preference.dart'; // Import ClientSchedulePreference

class ClientPreferenceSchedule extends ConsumerStatefulWidget {
  const ClientPreferenceSchedule({super.key});

  @override
  ConsumerState<ClientPreferenceSchedule> createState() => _ClientPreferenceScheduleState();
}

class _ClientPreferenceScheduleState extends ConsumerState<ClientPreferenceSchedule> {
  final _formKey = GlobalKey<FormState>();
  final Map<int, TextEditingController> _preferredStartTimes = {};
  final Map<int, TextEditingController> _preferredEndTimes = {};

  // Add a state to hold fetched client preferences
  AsyncValue<List<ClientSchedulePreference>> _clientPreferences = const AsyncValue.loading();

  @override
  void initState() {
    super.initState();
    _fetchClientPreferences();
  }

  Future<void> _fetchClientPreferences() async {
    _clientPreferences = const AsyncValue.loading();
    try {
      final preferences = await ApiService.getClientPreferences();
      setState(() {
        _clientPreferences = AsyncValue.data(preferences);
        // Populate controllers with fetched preferences
        for (var pref in preferences) {
          _preferredStartTimes[pref.dayOfWeek]?.text = pref.preferredStartTime;
          _preferredEndTimes[pref.dayOfWeek]?.text = pref.preferredEndTime;
        }
      });
    } catch (e, st) {
      setState(() {
        _clientPreferences = AsyncValue.error(e, st);
      });
    }
  }

  @override
  void dispose() {
    _preferredStartTimes.forEach((key, controller) => controller.dispose());
    _preferredEndTimes.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

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

  String? _timeValidator(String? value, String availableStartTime, String availableEndTime) {
    if (value == null || value.isEmpty) {
      return null; // Not required to fill
    }
    final timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    if (!timeRegex.hasMatch(value)) {
      return 'Неверный формат (ЧЧ:ММ)';
    }

    // Further validation: check if within available range
    final inputTime = _parseTime(value);
    final start = _parseTime(availableStartTime);
    final end = _parseTime(availableEndTime);

    if (inputTime.isBefore(start) || inputTime.isAfter(end)) {
      return 'Время вне доступного диапазона';
    }

    return null;
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    final workSchedulesAsync = ref.watch(workScheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Предпочтения по расписанию'),
      ),
      body: Form(
        key: _formKey,
        child: workSchedulesAsync.when(
          data: (schedules) {
            final workingDays = schedules.where((s) => !s.isDayOff).toList();
            if (workingDays.isEmpty) {
              return const Center(child: Text('Нет доступного расписания работы центра.'));
            }

            // Combine work schedules with client preferences
            // This ensures controllers are initialized and then populated
            _clientPreferences.whenOrNull(
              data: (preferences) {
                for (var pref in preferences) {
                  _preferredStartTimes.putIfAbsent(pref.dayOfWeek, () => TextEditingController()).text = pref.preferredStartTime;
                  _preferredEndTimes.putIfAbsent(pref.dayOfWeek, () => TextEditingController()).text = pref.preferredEndTime;
                }
              },
            );

            return ListView.builder(
              itemCount: workingDays.length,
              itemBuilder: (context, index) {
                final schedule = workingDays[index];
                final dayOfWeek = schedule.dayOfWeek;

                // Ensure controllers are initialized for this day if not already by fetched preferences
                _preferredStartTimes.putIfAbsent(dayOfWeek, () => TextEditingController());
                _preferredEndTimes.putIfAbsent(dayOfWeek, () => TextEditingController());

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _dayOfWeekToString(dayOfWeek),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text('Доступно: ${schedule.startTime} - ${schedule.endTime}'),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _preferredStartTimes[dayOfWeek],
                          decoration: const InputDecoration(
                            labelText: 'Желаемое время начала (ЧЧ:ММ)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => _timeValidator(value, schedule.startTime, schedule.endTime),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _preferredEndTimes[dayOfWeek],
                          decoration: const InputDecoration(
                            labelText: 'Желаемое время окончания (ЧЧ:ММ)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => _timeValidator(value, schedule.startTime, schedule.endTime),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Ошибка загрузки расписания: $error')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async { // Make onPressed async
          if (_formKey.currentState!.validate()) {
            final List<ClientSchedulePreference> preferencesToSave = [];
            _preferredStartTimes.forEach((day, controller) {
              if (controller.text.isNotEmpty && _preferredEndTimes[day]!.text.isNotEmpty) {
                preferencesToSave.add(ClientSchedulePreference(
                  clientId: 0, // Will be set by backend from token
                  dayOfWeek: day,
                  preferredStartTime: controller.text,
                  preferredEndTime: _preferredEndTimes[day]!.text,
                ));
              }
            });

            try {
              await ApiService.saveClientPreferences(preferencesToSave);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Предпочтения сохранены!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              // Re-fetch preferences to ensure UI is updated if needed
              _fetchClientPreferences();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ошибка сохранения предпочтений: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}