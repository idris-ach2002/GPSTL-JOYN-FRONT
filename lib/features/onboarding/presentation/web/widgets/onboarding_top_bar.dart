import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/components/joyn_logo.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';

/// Barre blanche du haut : logo à gauche, contenu central optionnel,
/// action à droite. Sur petit écran, le contenu central passe en dessous.
class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({
    required this.trailing,
    this.center,
    this.maxWidth = 1120,
    super.key,
  });

  final Widget? center;
  final Widget trailing;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 640;

    final logo = Semantics(
      link: true,
      label: "Joyn, retour à l'accueil",
      excludeSemantics: true,
      child: InkWell(
        onTap: () => context.go(AppRoutes.dashboard),
        borderRadius: BorderRadius.circular(10),
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: JoynLogo(markSize: 28),
        ),
      ),
    );

    final Widget content;
    if (compact) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [logo, const Spacer(), trailing]),
          if (center != null) ...[const SizedBox(height: 12), center!],
        ],
      );
    } else {
      content = Row(
        children: [
          logo,
          const SizedBox(width: 20),
          Expanded(
            child: center == null
                ? const SizedBox.shrink()
                : Align(alignment: Alignment.center, child: center),
          ),
          const SizedBox(width: 20),
          trailing,
        ],
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.lineSoft)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: content,
          ),
        ),
      ),
    );
  }
}
