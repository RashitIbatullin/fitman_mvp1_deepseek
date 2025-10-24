import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';
import 'admin/create_user_screen.dart';
import 'admin/users_list_screen.dart';
import 'admin/work_schedule_screen.dart';
import 'admin/catalogs_screen.dart'; // Import the new CatalogsScreen

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _selectedIndex = 0;

      final List<Widget> _views = const [
      CatalogsScreen(),    Center(child: Text('Настройки - в разработке')),
    Center(child: Text('Аналитика - в разработке')),
    UsersListScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToCreateUser(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateUserScreen(userRole: role),
      ),
    ).then((created) {
      if (created == true) {
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
              _navigateToCreateUser(context, 'instructor');
            },
            child: const Text('Инструктор'),
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
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: CustomAppBar.admin(
        title: 'Администратор: ${user?.firstName ?? ''}',
        onTabSelected: _onTabSelected,
        additionalActions: [
          AppBarAction(
            icon: Icons.person_add,
            label: 'Создать',
            onPressed: () => _showCreateUserDialog(context),
          ),
          AppBarAction(
            icon: Icons.people,
            label: 'Пользователи',
            onPressed: () {
              setState(() {
                _selectedIndex = 3;
              });
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _views,
      ),
    );
  }
}
