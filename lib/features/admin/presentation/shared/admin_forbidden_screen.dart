import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import 'admin_ui.dart';

/// Page 403 : affichée quand un compte sans le rôle `admin` tente d'ouvrir
/// l'espace d'administration.
class AdminForbiddenScreen extends StatelessWidget {
  const AdminForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return JoynMaterialScope(
      child: Scaffold(
        body: SafeArea(
          child: AdminForbiddenView(
            onLeave: () => context.go(AppRoutes.dashboard),
          ),
        ),
      ),
    );
  }
}
