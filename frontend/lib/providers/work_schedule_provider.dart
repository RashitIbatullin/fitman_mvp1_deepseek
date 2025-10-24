import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../models/work_schedule.dart';
import '../../services/api_service.dart';

final workScheduleProvider = StateNotifierProvider<WorkScheduleNotifier, AsyncValue<List<WorkSchedule>>>((ref) {
  return WorkScheduleNotifier();
});

class WorkScheduleNotifier extends StateNotifier<AsyncValue<List<WorkSchedule>>> {
  WorkScheduleNotifier() : super(const AsyncValue.loading()) {
    _fetchWorkSchedules();
  }

  Future<void> _fetchWorkSchedules() async {
    try {
      final schedules = await ApiService.getWorkSchedules();
      state = AsyncValue.data(schedules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateWorkSchedule(WorkSchedule schedule) async {
    try {
      await ApiService.updateWorkSchedule(schedule);
      _fetchWorkSchedules();
    } catch (e) {
      // Handle error
    }
  }
}
