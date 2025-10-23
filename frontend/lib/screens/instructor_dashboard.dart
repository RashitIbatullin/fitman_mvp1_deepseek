import 'package:fitman_app/screens/instructor/clients_view.dart';
import 'package:fitman_app/screens/instructor/my_manager_view.dart';
import 'package:fitman_app/screens/instructor/my_trainer_view.dart';
import 'package:fitman_app/screens/instructor/schedule_view.dart';
import 'package:fitman_app/screens/instructor/timesheet_view.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class InstructorDashboard extends StatefulWidget {
  const InstructorDashboard({super.key});

  @override
  State<InstructorDashboard> createState() => _InstructorDashboardState();
}

class _InstructorDashboardState extends State<InstructorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _views = const [
    ClientsView(),
    MyTrainerView(),
    MyManagerView(),
    ScheduleView(),
    TimesheetView(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.instructor(
        title: 'Панель инструктора',
        onTabSelected: _onTabSelected,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _views,
      ),
    );
  }
}
