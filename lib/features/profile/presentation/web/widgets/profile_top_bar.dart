import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/components/joyn_logo.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';

/// Barre blanche du haut des pages profil : logo, retour, actions.
class ProfileTopBar extends StatelessWidget {
  const ProfileTopBar({
    required this.leading,
    this.actions = const [],
    super.key,
  });

  /// Bouton de retour (vers le tableau de bord ou le profil).
  final Widget leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 640;

    return Material(
      color: AppColors.surface,
      shape: const Border(bottom: BorderSide(color: AppColors.lineSoft)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              children: [
                if (!compact) ...[
                  Tooltip(
                    message: 'Tableau de bord',
                    child: InkWell(
                      onTap: () => context.go(AppRoutes.dashboard),
                      borderRadius: BorderRadius.circular(10),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: JoynLogo(markSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                leading,
                const Spacer(),
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  actions[i],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
