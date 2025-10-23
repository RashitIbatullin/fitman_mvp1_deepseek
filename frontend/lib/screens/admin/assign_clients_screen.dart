import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_front.dart';
import '../../services/api_service.dart';

// Провайдер для получения всех клиентов
final allClientsProvider = FutureProvider<List<User>>((ref) async {
  return ApiService.getUsers(role: 'client');
});

// Провайдер для получения ID назначенных клиентов для конкретного менеджера
final assignedClientIdsProvider = FutureProvider.family<List<int>, int>((ref, managerId) async {
  return ApiService.getAssignedClientIds(managerId);
});

class AssignClientsScreen extends ConsumerStatefulWidget {
  final User manager;

  const AssignClientsScreen({super.key, required this.manager});

  @override
  ConsumerState<AssignClientsScreen> createState() => _AssignClientsScreenState();
}

class _AssignClientsScreenState extends ConsumerState<AssignClientsScreen> {
  final Set<int> _selectedClientIds = {};
  bool _isInitialLoad = true;

  @override
  Widget build(BuildContext context) {
    final allClientsAsync = ref.watch(allClientsProvider);
    final assignedIdsAsync = ref.watch(assignedClientIdsProvider(widget.manager.id));

    // Инициализируем выбранные ID при первой загрузке
    if (_isInitialLoad && assignedIdsAsync is AsyncData<List<int>>) {
      _selectedClientIds.clear();
      _selectedClientIds.addAll(assignedIdsAsync.value);
      // Устанавливаем флаг в false, чтобы это не повторялось при каждой перерисовке
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isInitialLoad = false;
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Клиенты для ${widget.manager.shortName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Сохранить',
            onPressed: _saveAssignments,
          ),
        ],
      ),
      body: allClientsAsync.when(
        data: (allClients) {
          if (allClients.isEmpty) {
            return const Center(child: Text('В системе нет ни одного клиента.'));
          }
          return ListView.builder(
            itemCount: allClients.length,
            itemBuilder: (context, index) {
              final client = allClients[index];
              return CheckboxListTile(
                title: Text(client.fullName),
                subtitle: Text(client.email),
                value: _selectedClientIds.contains(client.id),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedClientIds.add(client.id);
                    } else {
                      _selectedClientIds.remove(client.id);
                    }
                  });
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Ошибка загрузки списка клиентов: $e')),
      ),
    );
  }

  Future<void> _saveAssignments() async {
    try {
      await ApiService.assignClientsToManager(widget.manager.id, _selectedClientIds.toList());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Назначения успешно сохранены')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
        );
      }
    }
  }
}