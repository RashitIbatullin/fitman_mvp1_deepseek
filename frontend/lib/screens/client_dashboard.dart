import '../models/dashboard_data.dart';
import 'package:fitman_app/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/user_front.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';
import 'client/my_trainer_screen.dart';
import 'client/my_instructor_screen.dart';
import 'client/my_manager_screen.dart';
import 'client/anthropometry_screen.dart';
import 'client/sessions_screen.dart';
import 'client/calorie_tracking_screen.dart';
import 'client/progress_screen.dart';

class ClientDashboard extends ConsumerWidget {
  final User? client;

  const ClientDashboard({super.key, this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = client ?? ref.watch(authProvider).value;
    final dashboardData = ref.watch(dashboardDataProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Пользователь не найден')),
      );
    }

    return Scaffold(
      appBar: CustomAppBar.client(
        title: 'Профиль: ${user.firstName}',
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Навигация к уведомлениям
            },
          ),
        ],
        showBackButton: client != null,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Меню',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Мой тренер'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyTrainerScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Мой инструктор'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyInstructorScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.business_center),
              title: Text('Мой менеджер'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyManagerScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.accessibility),
              title: Text('Антропометрия'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AnthropometryScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.fitness_center),
              title: Text('Занятия'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SessionsScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.track_changes),
              title: Text('Учет калорий'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CalorieTrackingScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.show_chart),
              title: Text('Прогресс'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgressScreen()));
              },
            ),
          ],
        ),
      ),
      body: dashboardData.when(
        data: (data) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildNextTrainingWidget(context, data.nextTraining),
            const SizedBox(height: 16),
            _buildTrainingProgressWidget(context, data.trainingProgress),
            const SizedBox(height: 16),
            _buildGoalProgressWidget(context, data.goalProgress),
            const SizedBox(height: 16),
            _buildAchievementsWidget(context, data.achievements),
            const SizedBox(height: 16),
            _buildQuickMenu(context),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  Widget _buildNextTrainingWidget(BuildContext context, NextTraining data) {
    final duration = data.time.difference(DateTime.now());
    final formattedDuration = duration.isNegative ? 'Прошло' : '${duration.inHours} ч ${duration.inMinutes.remainder(60)} мин';

    return Card(
      child: ListTile(
        leading: Icon(Icons.watch_later_outlined, color: Colors.orange, size: 40),
        title: Text(data.title),
        subtitle: Text('${DateFormat('d MMM y, HH:mm', 'ru').format(data.time)}\nДо начала: $formattedDuration'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }

  Widget _buildTrainingProgressWidget(BuildContext context, TrainingProgress data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Прогресс тренировок', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressItem(context, 'Завершено', '${data.completed}/${data.total}'),
                _buildProgressItem(context, 'Сожжено ккал', data.caloriesBurned.toString()),
                _buildProgressItem(context, 'Посещаемость', '${data.attendance}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgressWidget(BuildContext context, GoalProgress data) {
    final progress = (data.targetWeight - data.currentWeight).abs() / (data.targetWeight - 85).abs(); // Assuming starting weight is 85

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Прогресс по цели: ${data.goal}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: LinearProgressIndicator(value: progress, minHeight: 10)),
                const SizedBox(width: 16),
                Text('${data.currentWeight}/${data.targetWeight} кг', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text('Средний дефицит: ${data.avgDeficit} ккал/день'),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsWidget(BuildContext context, List<Achievement> data) {
    final iconMap = {
      'star': Icons.star,
      'local_fire_department': Icons.local_fire_department,
      'fitness_center': Icons.fitness_center,
    };
    final colorMap = {
      'amber': Colors.amber,
      'red': Colors.red,
      'blue': Colors.blue,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Достижения', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.map((ach) => Icon(iconMap[ach.icon], color: colorMap[ach.color], size: 40)).toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMenu(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SessionsScreen()));
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.fitness_center, size: 40, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 8),
                    Text('Занятия'),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.track_changes, size: 40, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 8),
                    Text('Учет калорий'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressItem(BuildContext context, String title, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
