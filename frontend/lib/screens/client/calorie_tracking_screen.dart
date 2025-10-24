import 'package:fitman_app/models/calorie_tracking_data.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final calorieTrackingProvider = FutureProvider<List<CalorieTrackingData>>((ref) async {
  final data = await ApiService.getCalorieTrackingData();
  return data.map((item) => CalorieTrackingData.fromJson(item)).toList();
});

class CalorieTrackingScreen extends ConsumerWidget {
  const CalorieTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calorieTrackingData = ref.watch(calorieTrackingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Учет калорий'),
      ),
      body: calorieTrackingData.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return ListTile(
              title: Text('${item.training} - ${DateFormat('d MMM y', 'ru').format(item.date)}'),
              subtitle: Text('Потреблено: ${item.consumed} ккал, Затрачено: ${item.burned} ккал'),
              trailing: Text('${item.balance > 0 ? '+' : ''}${item.balance} ккал', style: TextStyle(color: item.balance > 0 ? Colors.red : Colors.green)),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Ошибка: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new calorie entry
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
