
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// TODO: Integrate with backend to fetch actual work_schedules
// For now, using dummy data for work schedules
class WorkSchedule {
  final int dayOfWeek; // 1 for Monday, 7 for Sunday
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isDayOff;

  WorkSchedule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isDayOff = false,
  });
}

final List<WorkSchedule> dummyWorkSchedules = [
  WorkSchedule(dayOfWeek: 1, startTime: TimeOfDay(hour: 9, minute: 0), endTime: TimeOfDay(hour: 20, minute: 0)), // Monday
  WorkSchedule(dayOfWeek: 2, startTime: TimeOfDay(hour: 9, minute: 0), endTime: TimeOfDay(hour: 20, minute: 0)), // Tuesday
  WorkSchedule(dayOfWeek: 3, startTime: TimeOfDay(hour: 9, minute: 0), endTime: TimeOfDay(hour: 20, minute: 0)), // Wednesday
  WorkSchedule(dayOfWeek: 4, startTime: TimeOfDay(hour: 9, minute: 0), endTime: TimeOfDay(hour: 20, minute: 0)), // Thursday
  WorkSchedule(dayOfWeek: 5, startTime: TimeOfDay(hour: 9, minute: 0), endTime: TimeOfDay(hour: 20, minute: 0)), // Friday
  WorkSchedule(dayOfWeek: 6, startTime: TimeOfDay(hour: 10, minute: 0), endTime: TimeOfDay(hour: 18, minute: 0), isDayOff: false), // Saturday
  WorkSchedule(dayOfWeek: 7, startTime: TimeOfDay(hour: 0, minute: 0), endTime: TimeOfDay(hour: 0, minute: 0), isDayOff: true), // Sunday
];


class ClientPreferenceSchedule extends ConsumerStatefulWidget {
  const ClientPreferenceSchedule({super.key});

  @override
  ConsumerState<ClientPreferenceSchedule> createState() => _ClientPreferenceScheduleState();
}

class _ClientPreferenceScheduleState extends ConsumerState<ClientPreferenceSchedule> {
  final Map<int, TimeOfDay?> _preferredStartTimes = {};
  final Map<int, TimeOfDay?> _preferredEndTimes = {};

  @override
  Widget build(BuildContext context) {
    final workingDays = dummyWorkSchedules.where((s) => !s.isDayOff).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Предпочтения по расписанию'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: workingDays.length,
              itemBuilder: (context, index) {
                final daySchedule = workingDays[index];
                final dayName = DateFormat('EEEE', 'ru').format(
                  DateTime(2023, 1, daySchedule.dayOfWeek), // Use a fixed date to get day name
                );
                final availableStartTime = daySchedule.startTime;
                final availableEndTime = daySchedule.endTime;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$dayName (доступно с ${availableStartTime.format(context)} до ${availableEndTime.format(context)})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimePicker(
                                  context,
                                  daySchedule.dayOfWeek,
                                  true, // isStartTime
                                  availableStartTime,
                                  availableEndTime,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTimePicker(
                                  context,
                                  daySchedule.dayOfWeek,
                                  false, // isStartTime
                                  availableStartTime,
                                  availableEndTime,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement save logic
                    print('Preferred Start Times: $_preferredStartTimes');
                    print('Preferred End Times: $_preferredEndTimes');
                    Navigator.pop(context); // Go back
                  },
                  child: const Text('Сохранить'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back without saving
                  },
                  child: const Text('Отмена'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    int dayOfWeek,
    bool isStartTime,
    TimeOfDay availableStartTime,
    TimeOfDay availableEndTime,
  ) {
    final selectedTime = isStartTime ? _preferredStartTimes[dayOfWeek] : _preferredEndTimes[dayOfWeek];

    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? (isStartTime ? availableStartTime : availableEndTime),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            if (isStartTime) {
              _preferredStartTimes[dayOfWeek] = picked;
            } else {
              _preferredEndTimes[dayOfWeek] = picked;
            }
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isStartTime ? 'Начало' : 'Окончание',
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              selectedTime?.format(context) ?? 'Выберите время',
            ),
            const Icon(Icons.access_time),
          ],
        ),
      ),
    );
  }
}
