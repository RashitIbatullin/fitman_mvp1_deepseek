import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/dialog_utils.dart';

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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // Фабричные методы для разных ролей
  factory CustomAppBar.client({
    String title = 'Фитнес-трекер',
    List<Widget>? additionalActions,
  }) {
    final defaultActions = [
      IconButton(icon: const Icon(Icons.calendar_today), onPressed: () {}),
      IconButton(icon: const Icon(Icons.assessment), onPressed: () {}),
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
      IconButton(icon: const Icon(Icons.group), onPressed: () {}),
      IconButton(icon: const Icon(Icons.schedule), onPressed: () {}),
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
      IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
      IconButton(icon: const Icon(Icons.analytics), onPressed: () {}),
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
    );
  }

  Widget _buildLogoutAction(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Выйти из системы',
          onPressed: () {
            DialogUtils.showLogoutDialog(context, ref);
          },
        );
      },
    );
  }
}