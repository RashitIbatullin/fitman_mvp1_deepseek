import 'package:flutter/material.dart';
import 'package:fitman_app/screens/manager/trainers_view.dart';

import 'manager/clients_view.dart';
import 'manager/instructors_view.dart';
import 'manager/schedule_view.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6, // Клиенты, Инструкторы, Тренеры, Расписание, Табели, Каталоги
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manager Dashboard'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Клиенты'),
              Tab(icon: Icon(Icons.sports), text: 'Инструкторы'),
              Tab(icon: Icon(Icons.fitness_center), text: 'Тренеры'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Расписание'),
              Tab(icon: Icon(Icons.access_time), text: 'Табели'),
              Tab(icon: Icon(Icons.folder_open), text: 'Каталоги'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ClientsView(),
            InstructorsView(),
            TrainersView(),
            ScheduleView(),
            // Placeholder for Timesheets
            Center(child: Text('Табели - в разработке')),
            // Placeholder for Catalogs
            Center(child: Text('Каталоги - в разработке')),
          ],
        ),
      ),
    );
  }
}
