import 'package:flutter/material.dart';

class TimesheetView extends StatelessWidget {
  const TimesheetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time_filled, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Табель в разработке',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Здесь будет отображаться ваш табель учета рабочего времени с разбивкой по дням, неделям и месяцам.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
