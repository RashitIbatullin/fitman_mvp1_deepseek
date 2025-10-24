import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // This import might not be needed if not using GoRouter directly here
import 'work_schedule_screen.dart'; // Import the WorkScheduleScreen
import 'generic_catalog_screen.dart'; // Import the GenericCatalogScreen
import 'generic_catalog_screen.dart'; // Import the GenericCatalogScreen

class CatalogsScreen extends StatelessWidget {
  const CatalogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталоги'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Расписание работы центра'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkScheduleScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Виды активности клиента'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenericCatalogScreen(catalogName: 'Виды активности клиента')),
              );
            },
          ),
          ListTile(
            title: const Text('Уровни фитнес-подготовки'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenericCatalogScreen(catalogName: 'Уровни фитнес-подготовки')),
              );
            },
          ),
          ListTile(
            title: const Text('Цели тренировок'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenericCatalogScreen(catalogName: 'Цели тренировок')),
              );
            },
          ),
          ListTile(
            title: const Text('Типы телосложения'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenericCatalogScreen(catalogName: 'Типы телосложения')),
              );
            },
          ),
          ListTile(
            title: const Text('Виды оборудования'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenericCatalogScreen(catalogName: 'Виды оборудования')),
              );
            },
          ),
          ListTile(
            title: const Text('Типы оборудования'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenericCatalogScreen(catalogName: 'Типы оборудования')),
              );
            },
          ),
          ListTile(
            title: const Text('Виды Упражнений'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenericCatalogScreen(catalogName: 'Виды Упражнений')),
              );
            },
          ),
          ListTile(
            title: const Text('Типы Упражнений'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenericCatalogScreen(catalogName: 'Типы Упражнений')),
              );
            },
          ),
          ListTile(
            title: const Text('Упражнения'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenericCatalogScreen(catalogName: 'Упражнения')),
              );
            },
          ),
          ListTile(
            title: const Text('Набор упражнений'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenericCatalogScreen(catalogName: 'Набор упражнений')),
              );
            },
          ),
          ListTile(
            title: const Text('Планы тренировок'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenericCatalogScreen(catalogName: 'Планы тренировок')),
              );
            },
          ),
          ListTile(
            title: const Text('Заявки (Лид-менеджмент)'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenericCatalogScreen(catalogName: 'Заявки (Лид-менеджмент)')),
              );
            },
          ),
          ListTile(
            title: const Text('Дежурства сотрудников'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenericCatalogScreen(catalogName: 'Дежурства сотрудников')),
              );
            },
          ),
          ListTile(
            title: const Text('Квалификации'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenericCatalogScreen(catalogName: 'Квалификации')),
              );
            },
          ),
        ],
      ),
    );
  }
}