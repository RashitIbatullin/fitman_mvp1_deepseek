import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/dialog_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogout;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showLogout = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: showLogout
          ? [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  // Получаем ref через ProviderScope
                  final ref = ProviderScope.containerOf(context);
                  DialogUtils.showLogoutDialog(context, ref);
                },
              ),
            ]
          : null,
    );
  }
}