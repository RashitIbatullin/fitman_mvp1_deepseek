import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_front.dart';
import '../../services/api_service.dart';

// Провайдер для получения всех инструкторов
final allInstructorsProvider = FutureProvider<List<User>>((ref) async {
  return ApiService.getUsers(role: 'instructor');
});

// Провайдер для получения ID назначенных инструкторов для конкретного менеджера
final assignedInstructorIdsProvider = FutureProvider.family<List<int>, int>((ref, managerId) async {
  // TODO: Implement ApiService.getAssignedInstructorIds
  return ApiService.getAssignedInstructorIds(managerId);
});

class AssignInstructorsScreen extends ConsumerStatefulWidget {
  final User manager;

  const AssignInstructorsScreen({super.key, required this.manager});

  @override
  ConsumerState<AssignInstructorsScreen> createState() => _AssignInstructorsScreenState();
}

class _AssignInstructorsScreenState extends ConsumerState<AssignInstructorsScreen> {
  final Set<int> _selectedInstructorIds = {};
  bool _isInitialLoad = true;

  @override
  Widget build(BuildContext context) {
    final allInstructorsAsync = ref.watch(allInstructorsProvider);
    final assignedIdsAsync = ref.watch(assignedInstructorIdsProvider(widget.manager.id));

    if (_isInitialLoad && assignedIdsAsync is AsyncData<List<int>>) {
      _selectedInstructorIds.clear();
      _selectedInstructorIds.addAll(assignedIdsAsync.value);
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
        title: Text('Инструкторы для ${widget.manager.shortName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Сохранить',
            onPressed: _saveAssignments,
          ),
        ],
      ),
      body: allInstructorsAsync.when(
        data: (allInstructors) {
          if (allInstructors.isEmpty) {
            return const Center(child: Text('В системе нет ни одного инструктора.'));
          }
          return ListView.builder(
            itemCount: allInstructors.length,
            itemBuilder: (context, index) {
              final instructor = allInstructors[index];
              return CheckboxListTile(
                title: Text(instructor.fullName),
                subtitle: Text(instructor.email),
                value: _selectedInstructorIds.contains(instructor.id),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedInstructorIds.add(instructor.id);
                    } else {
                      _selectedInstructorIds.remove(instructor.id);
                    }
                  });
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Ошибка загрузки списка инструкторов: $e')),
      ),
    );
  }

  Future<void> _saveAssignments() async {
    try {
      // TODO: Implement ApiService.assignInstructorsToManager
      await ApiService.assignInstructorsToManager(widget.manager.id, _selectedInstructorIds.toList());
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
