import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/dialog_utils.dart';

class AppBarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const AppBarAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28.0),
            const SizedBox(height: 2.0),
            Text(label, style: const TextStyle(fontSize: 10.0)),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool showLogout;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.showLogout = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);

  factory CustomAppBar.client({
    String title = 'Фитнес-трекер',
    List<Widget>? additionalActions,
  }) {
    final defaultActions = [
      AppBarAction(icon: Icons.calendar_today, label: 'Расписание', onPressed: () {}),
      AppBarAction(icon: Icons.assessment, label: 'Прогресс', onPressed: () {}),
    ];

    return CustomAppBar(
      title: title,
      actions: [
        ...?additionalActions,
        ...defaultActions,
      ],
    );
  }

  factory CustomAppBar.trainer({
    String title = 'Панель тренера',
    List<Widget>? additionalActions,
  }) {
    final defaultActions = [
      AppBarAction(icon: Icons.group, label: 'Клиенты', onPressed: () {}),
      AppBarAction(icon: Icons.schedule, label: 'Расписание', onPressed: () {}),
    ];

    return CustomAppBar(
      title: title,
      actions: [
        ...?additionalActions,
        ...defaultActions,
      ],
    );
  }

  factory CustomAppBar.admin({
    String title = 'Администрирование',
    List<Widget>? additionalActions,
  }) {
    final defaultActions = [
      AppBarAction(icon: Icons.settings, label: 'Настройки', onPressed: () {}),
      AppBarAction(icon: Icons.analytics, label: 'Аналитика', onPressed: () {}),
    ];

    return CustomAppBar(
      title: title,
      actions: [
        ...?additionalActions,
        ...defaultActions,
      ],
    );
  }

  factory CustomAppBar.manager({
    String title = 'Панель менеджера',
    List<Widget>? additionalActions,
    required Function(int) onTabSelected,
  }) {
    final defaultActions = [
      AppBarAction(icon: Icons.people, label: 'Клиенты', onPressed: () => onTabSelected(0)),
      AppBarAction(icon: Icons.sports, label: 'Инструкторы', onPressed: () => onTabSelected(1)),
      AppBarAction(icon: Icons.fitness_center, label: 'Тренеры', onPressed: () => onTabSelected(2)),
      AppBarAction(icon: Icons.calendar_today, label: 'Расписание', onPressed: () => onTabSelected(3)),
      AppBarAction(icon: Icons.access_time, label: 'Табели', onPressed: () => onTabSelected(4)),
      AppBarAction(icon: Icons.folder_open, label: 'Каталоги', onPressed: () => onTabSelected(5)),
    ];

    return CustomAppBar(
      title: title,
      actions: [
        ...?additionalActions,
        ...defaultActions,
      ],
    );
  }

  factory CustomAppBar.instructor({
    String title = 'Панель инструктора',
    List<Widget>? additionalActions,
    required Function(int) onTabSelected,
  }) {
    final defaultActions = [
      AppBarAction(icon: Icons.people, label: 'Клиенты', onPressed: () => onTabSelected(0)),
      AppBarAction(icon: Icons.person, label: 'Тренер', onPressed: () => onTabSelected(1)),
      AppBarAction(icon: Icons.manage_accounts, label: 'Менеджер', onPressed: () => onTabSelected(2)),
      AppBarAction(icon: Icons.calendar_today, label: 'Расписание', onPressed: () => onTabSelected(3)),
      AppBarAction(icon: Icons.access_time, label: 'Табель', onPressed: () => onTabSelected(4)),
    ];

    return CustomAppBar(
      title: title,
      actions: [
        ...?additionalActions,
        ...defaultActions,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        ...?actions,
        if (showLogout) _buildLogoutAction(context),
      ],
      toolbarHeight: preferredSize.height,
    );
  }

  Widget _buildLogoutAction(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return IconButton(
          icon: const Icon(Icons.logout, size: 30.0),
          tooltip: 'Выйти из системы',
          onPressed: () {
            DialogUtils.showLogoutDialog(context, ref);
          },
        );
      },
    );
  }
}