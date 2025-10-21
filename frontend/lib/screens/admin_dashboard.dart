import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';
import 'admin/create_user_screen.dart';
import 'admin/users_list_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  void _navigateToCreateUser(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateUserScreen(userRole: role),
      ),
    ).then((created) {
      if (created == true) {
        // Можно обновить список пользователей если нужно
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пользователь успешно создан')),
        );
      }
    });
  }

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать пользователя'),
        content: const Text('Выберите роль нового пользователя:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCreateUser(context, 'client');
            },
            child: const Text('Клиент'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCreateUser(context, 'trainer');
            },
            child: const Text('Тренер'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCreateUser(context, 'admin');
            },
            child: const Text('Администратор'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: CustomAppBar.admin(
        title: 'Администратор: ${user?.firstName ?? ''}',
        additionalActions: [
          // Кнопка создания пользователя
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Создать пользователя',
            onPressed: () => _showCreateUserDialog(context),
          ),
          // Кнопка списка пользователей
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Список пользователей',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UsersListScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статистика
            _buildStatsCard(context),
            const SizedBox(height: 24),

            // Быстрые действия
            _buildQuickActions(context),
            const SizedBox(height: 24),

            // Последние действия
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Клиенты', '45', Icons.people, Colors.blue),
            _buildStatItem('Тренеры', '5', Icons.sports, Colors.green),
            _buildStatItem('Админы', '2', Icons.admin_panel_settings, Colors.purple),
            _buildStatItem('Занятия', '128', Icons.fitness_center, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Быстрые действия',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionCard(
              'Создать клиента',
              Icons.person_add,
              Colors.blue,
                  () => _navigateToCreateUser(context, 'client'),
            ),
            _buildActionCard(
              'Создать тренера',
              Icons.sports,
              Colors.green,
                  () => _navigateToCreateUser(context, 'trainer'),
            ),
            _buildActionCard(
              'Список пользователей',
              Icons.people,
              Colors.purple,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UsersListScreen()),
                );
              },
            ),
            _buildActionCard(
              'Настройки системы',
              Icons.settings,
              Colors.orange,
                  () {
                // Навигация к настройкам
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Последние действия',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.person_add, color: Colors.green),
                      title: Text('Создан новый клиент: Иванов Иван'),
                      subtitle: Text('2 часа назад'),
                    ),
                    ListTile(
                      leading: Icon(Icons.edit, color: Colors.blue),
                      title: Text('Обновлен профиль тренера: Петр Сидоров'),
                      subtitle: Text('5 часов назад'),
                    ),
                    ListTile(
                      leading: Icon(Icons.fitness_center, color: Colors.orange),
                      title: Text('Создано новое расписание'),
                      subtitle: Text('Вчера'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}