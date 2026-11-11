import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/auth_controller.dart';
import '../shared/admin_section.dart';

export '../shared/admin_section.dart';

/// Menu de l'espace admin sur mobile : changer de rubrique, se déconnecter.
class MobileAdminSectionMenu extends StatelessWidget {
  const MobileAdminSectionMenu({required this.current, super.key});

  final AdminSection current;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Object>(
      key: const ValueKey('mobile-admin-menu'),
      tooltip: 'Menu administration',
      icon: const Icon(Icons.menu_rounded),
      onSelected: (value) {
        if (value case final AdminSection section) {
          if (section != current) context.go(section.route);
        } else {
          context.read<AuthController>().signOut();
        }
      },
      itemBuilder: (context) => [
        for (final section in AdminSection.values)
          PopupMenuItem<Object>(
            value: section,
            child: ListTile(
              selected: section == current,
              leading: Icon(section.icon),
              title: Text(section.label),
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<Object>(
          value: 'signOut',
          child: ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text('Se déconnecter'),
          ),
        ),
      ],
    );
  }
}
