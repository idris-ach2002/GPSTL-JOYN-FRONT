import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../routing/app_routes.dart';

enum _AccountAction { profile, signOut }

class CandidateAccountMenu extends StatelessWidget {
  const CandidateAccountMenu({super.key, this.child, this.icon});

  final Widget? child;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_AccountAction>(
      tooltip: 'Mon profil',
      position: PopupMenuPosition.under,
      icon: icon,
      onSelected: (action) async {
        switch (action) {
          case _AccountAction.profile:
            context.go(AppRoutes.candidateProfile);
          case _AccountAction.signOut:
            await context.read<AuthController>().signOut();
            if (context.mounted) context.go(AppRoutes.login);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _AccountAction.profile,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.person_outline),
            title: Text('Voir mon profil'),
          ),
        ),
        PopupMenuItem(
          value: _AccountAction.signOut,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout_rounded),
            title: Text('Se déconnecter'),
          ),
        ),
      ],
      child: child,
    );
  }
}
