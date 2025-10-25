import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_front.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_app_bar.dart';
import 'create_user_screen.dart';
import 'assign_clients_screen.dart';
import 'assign_instructors_screen.dart';
import 'assign_trainers_screen.dart';
import '../client_dashboard.dart';
import '../instructor_dashboard.dart';
import '../manager_dashboard.dart';
import '../trainer_dashboard.dart';
import '../unknown_role_screen.dart';

class UsersListScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  const UsersListScreen({super.key, this.initialFilter});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _selectedFilter = widget.initialFilter!;
    }
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await ApiService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<User> get _filteredUsers {
    switch (_selectedFilter) {
      case 'admin':
        return _users.where((user) => user.role == 'admin').toList();
      case 'manager':
        return _users.where((user) => user.role == 'manager').toList();
      case 'trainer':
        return _users.where((user) => user.role == 'trainer').toList();
      case 'instructor':
        return _users.where((user) => user.role == 'instructor').toList();
      case 'client':
        return _users.where((user) => user.role == 'client').toList();
      default:
        return _users;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Администратор';
      case 'manager':
        return 'Менеджер';
      case 'trainer':
        return 'Тренер';
      case 'instructor':
        return 'Инструктор';
      case 'client':
        return 'Клиент';
      default:
        return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'manager':
        return Colors.orange;
      case 'trainer':
        return Colors.green;
      case 'client':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          // Фильтры
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('Все')),
                ButtonSegment(value: 'admin', label: Text('Админы')),
                ButtonSegment(value: 'manager', label: Text('Менеджеры')),
                ButtonSegment(value: 'trainer', label: Text('Тренеры')),
                ButtonSegment(value: 'client', label: Text('Клиенты')),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedFilter = newSelection.first;
                });
              },
            ),
          ),
          
          // Список пользователей
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Ошибка: $_error'))
                    : _filteredUsers.isEmpty
                        ? const Center(child: Text('Пользователи не найдены'))
                        : ListView.builder(
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getRoleColor(user.role),
                                    child: Text(
                                      user.firstName[0],
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(user.fullName),
                                  subtitle: Text(user.email),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Chip(
                                        label: Text(
                                          _getRoleDisplayName(user.role),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: _getRoleColor(user.role),
                                      ),
                                      if (user.role == 'manager') ...[
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.group_add),
                                          tooltip: 'Назначить клиентов',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AssignClientsScreen(manager: user),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.sports_kabaddi),
                                          tooltip: 'Назначить инструкторов',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AssignInstructorsScreen(manager: user),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.fitness_center),
                                          tooltip: 'Назначить тренеров',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AssignTrainersScreen(manager: user),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                  onTap: () {
                                    Widget page;
                                    switch (user.role) {
                                      case 'manager':
                                        page = ManagerDashboard(manager: user);
                                        break;
                                      case 'trainer':
                                        page = TrainerDashboard(trainer: user);
                                        break;
                                      case 'instructor':
                                        page = InstructorDashboard(instructor: user);
                                        break;
                                      case 'client':
                                        page = ClientDashboard(client: user);
                                        break;
                                      default:
                                        // Для админа или других ролей можно открыть экран редактирования или ничего не делать
                                        return; 
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => page),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      );
  }
}