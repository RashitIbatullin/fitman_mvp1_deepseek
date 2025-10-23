import 'package:flutter/material.dart';
import 'package:fitman_app/screens/manager/trainers_view.dart';

import '../widgets/custom_app_bar.dart';
import 'manager/clients_view.dart';
import 'manager/instructors_view.dart';
import 'manager/schedule_view.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _views = const [
    ClientsView(),
    InstructorsView(),
    TrainersView(),
    ScheduleView(),
    Center(child: Text('Табели - в разработке')),
    Center(child: Text('Каталоги - в разработке')),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.manager(
        title: 'Панель менеджера',
        onTabSelected: _onTabSelected,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _views,
      ),
    );
  }
}
