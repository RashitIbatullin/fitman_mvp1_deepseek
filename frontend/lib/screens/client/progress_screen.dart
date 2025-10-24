import 'package:fitman_app/models/progress_data.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final progressProvider = FutureProvider<ProgressData>((ref) async {
  final data = await ApiService.getProgressData();
  return ProgressData.fromJson(data);
});

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressData = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Прогресс'),
      ),
      body: progressData.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWeightChart(context, data.weight, data.calories),
              const SizedBox(height: 24),
              _buildCalorieChart(context, data.balance),
              const SizedBox(height: 24),
              _buildKpiCard(context, data.kpi),
              const SizedBox(height: 16),
              _buildRecommendationsCard(context, data.recommendations),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  Widget _buildWeightChart(BuildContext context, List<ChartDataPoint> weightData, List<ChartDataPoint> calorieData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('График веса и калорий', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: weightData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 4,
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: calorieData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 4,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieChart(BuildContext context, List<ChartDataPoint> balanceData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('График дефицита/профицита калорий', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: balanceData.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.value, color: e.value.value > 0 ? Colors.red : Colors.green)])).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(BuildContext context, KpiData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ключевые показатели', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildKpiItem(context, 'Средний вес', '${data.avgWeight.toStringAsFixed(1)} кг'),
                _buildKpiItem(context, 'Изменение веса', '${data.weightChange.toStringAsFixed(1)} кг'),
                _buildKpiItem(context, 'Сред. калории', '${data.avgCalories} ккал'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(BuildContext context, String recommendations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Рекомендации', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(recommendations),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiItem(BuildContext context, String title, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
