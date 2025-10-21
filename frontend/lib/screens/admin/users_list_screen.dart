import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_front.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_app_bar.dart';
import 'create_user_screen.dart';

class UsersListScreen extends ConsumerStatefulWidget {
  const UsersListScreen({super.key});

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
      case 'trainer':
        return _users.where((user) => user.role == 'trainer').toList();
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
      case 'trainer':
        return 'Тренер';
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
    return Scaffold(
      appBar: CustomAppBar.admin(
        title: 'Управление пользователями',
      ),
      body: Column(
        children: [
          // Фильтры
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('Все')),
                ButtonSegment(value: 'admin', label: Text('Админы')),
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
                                  trailing: Chip(
                                    label: Text(
                                      _getRoleDisplayName(user.role),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: _getRoleColor(user.role),
                                  ),
                                  onTap: () {
                                    // Навигация к редактированию пользователя
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateUserScreen(userRole: 'client'),
            ),
          ).then((_) => _loadUsers());
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}