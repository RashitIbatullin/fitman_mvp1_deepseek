import 'package:fitman_app/models/anthropometry_data.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final anthropometryProvider = FutureProvider<AnthropometryData>((ref) async {
  final data = await ApiService.getAnthropometryData();
  return AnthropometryData.fromJson(data);
});

class AnthropometryScreen extends ConsumerWidget {
  const AnthropometryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anthropometryData = ref.watch(anthropometryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Антропометрия'),
      ),
      body: anthropometryData.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Фиксированные значения', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Рост: ${data.fixed.height} см'),
                      Text('Обхват запястья: ${data.fixed.wristCirc} см'),
                      Text('Обхват лодыжки: ${data.fixed.ankleCirc} см'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Начало', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text('Вес: ${data.start.weight} кг'),
                            Text('Обхват плеч: ${data.start.shouldersCirc} см'),
                            Text('Обхват груди: ${data.start.breastCirc} см'),
                            Text('Обхват талии: ${data.start.waistCirc} см'),
                            Text('Обхват бедер: ${data.start.hipsCirc} см'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Окончание', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text('Вес: ${data.finish.weight} кг'),
                            Text('Обхват плеч: ${data.finish.shouldersCirc} см'),
                            Text('Обхват груди: ${data.finish.breastCirc} см'),
                            Text('Обхват талии: ${data.finish.waistCirc} см'),
                            Text('Обхват бедер: ${data.finish.hipsCirc} см'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Сравнить'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }
}
