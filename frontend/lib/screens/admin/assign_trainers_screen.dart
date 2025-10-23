import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_front.dart';
import '../../services/api_service.dart';

// Провайдер для получения всех тренеров
final allTrainersProvider = FutureProvider<List<User>>((ref) async {
  return ApiService.getUsers(role: 'trainer');
});

// Провайдер для получения ID назначенных тренеров для конкретного менеджера
final assignedTrainerIdsProvider = FutureProvider.family<List<int>, int>((ref, managerId) async {
  // TODO: Implement ApiService.getAssignedTrainerIds
  return ApiService.getAssignedTrainerIds(managerId);
});

class AssignTrainersScreen extends ConsumerStatefulWidget {
  final User manager;

  const AssignTrainersScreen({super.key, required this.manager});

  @override
  ConsumerState<AssignTrainersScreen> createState() => _AssignTrainersScreenState();
}

class _AssignTrainersScreenState extends ConsumerState<AssignTrainersScreen> {
  final Set<int> _selectedTrainerIds = {};
  bool _isInitialLoad = true;

  @override
  Widget build(BuildContext context) {
    final allTrainersAsync = ref.watch(allTrainersProvider);
    final assignedIdsAsync = ref.watch(assignedTrainerIdsProvider(widget.manager.id));

    if (_isInitialLoad && assignedIdsAsync is AsyncData<List<int>>) {
      _selectedTrainerIds.clear();
      _selectedTrainerIds.addAll(assignedIdsAsync.value);
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
        title: Text('Тренеры для ${widget.manager.shortName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Сохранить',
            onPressed: _saveAssignments,
          ),
        ],
      ),
      body: allTrainersAsync.when(
        data: (allTrainers) {
          if (allTrainers.isEmpty) {
            return const Center(child: Text('В системе нет ни одного тренера.'));
          }
          return ListView.builder(
            itemCount: allTrainers.length,
            itemBuilder: (context, index) {
              final trainer = allTrainers[index];
              return CheckboxListTile(
                title: Text(trainer.fullName),
                subtitle: Text(trainer.email),
                value: _selectedTrainerIds.contains(trainer.id),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedTrainerIds.add(trainer.id);
                    } else {
                      _selectedTrainerIds.remove(trainer.id);
                    }
                  });
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Ошибка загрузки списка тренеров: $e')),
      ),
    );
  }

  Future<void> _saveAssignments() async {
    try {
      // TODO: Implement ApiService.assignTrainersToManager
      await ApiService.assignTrainersToManager(widget.manager.id, _selectedTrainerIds.toList());
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
