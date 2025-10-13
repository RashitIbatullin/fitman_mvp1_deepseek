import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'schedule_screen.dart';

class ClientDashboardScreen extends ConsumerStatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  ConsumerState<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends ConsumerState<ClientDashboardScreen> {
  List<dynamic> _schedule = [];
  List<dynamic> _trainingPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final schedule = await ApiService.getSchedule();
      final plans = await ApiService.getTrainingPlans();
      
      setState(() {
        _schedule = schedule;
        _trainingPlans = plans;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой фитнес'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Приветствие
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              child: Icon(Icons.person, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Добро пожаловать!',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Рады видеть вас снова',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Ближайшее занятие
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.schedule, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'Ближайшее занятие',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_schedule.isNotEmpty)
                              ..._schedule.map((session) => _buildSessionCard(session)).toList()
                            else
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'Занятий не запланировано',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Мой план тренировок
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.fitness_center, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'Мой план тренировок',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_trainingPlans.isNotEmpty)
                              ..._trainingPlans.map((plan) => _buildPlanCard(plan)).toList()
                            else
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'План тренировок не назначен',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Быстрый доступ
                    Text(
                      'Быстрый доступ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildQuickAction(
                          Icons.schedule,
                          'Расписание',
                          Colors.blue,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ScheduleScreen()),
                            );
                          },
                        ),
                        _buildQuickAction(
                          Icons.monitor_weight,
                          'Учет калорий',
                          Colors.green,
                          () {
                            _showComingSoon('Учет калорий');
                          },
                        ),
                        _buildQuickAction(
                          Icons.trending_up,
                          'Прогресс',
                          Colors.orange,
                          () {
                            _showComingSoon('Отслеживание прогресса');
                          },
                        ),
                        _buildQuickAction(
                          Icons.chat,
                          'Чат с тренером',
                          Colors.purple,
                          () {
                            _showComingSoon('Чат с тренером');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    return Card(
      color: Colors.blue.shade50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.fitness_center, color: Colors.blue),
        title: Text(session['training_plan_name'] ?? 'Тренировка'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDateTime(session['start_time'])),
            if (session['trainer_name'] != null)
              Text('Тренер: ${session['trainer_name']}'),
          ],
        ),
        trailing: _buildStatusChip(session['status']),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    return Card(
      color: Colors.green.shade50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.list_alt, color: Colors.green),
        title: Text(plan['name']),
        subtitle: Text(plan['description'] ?? ''),
        trailing: Chip(
          label: Text(
            _getGoalText(plan['goal']),
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          backgroundColor: _getGoalColor(plan['goal']),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'completed':
        color = Colors.green;
        text = 'Завершено';
      case 'cancelled':
        color = Colors.red;
        text = 'Отменено';
      default:
        color = Colors.blue;
        text = 'Запланировано';
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  String _getGoalText(String goal) {
    switch (goal) {
      case 'weight_loss':
        return 'Похудение';
      case 'muscle_gain':
        return 'Масса';
      default:
        return goal;
    }
  }

  Color _getGoalColor(String goal) {
    switch (goal) {
      case 'weight_loss':
        return Colors.orange;
      case 'muscle_gain':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - скоро будет доступно!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleLogout() {
    ApiService.clearToken();
    Navigator.pushReplacementNamed(context, '/');
  }
}