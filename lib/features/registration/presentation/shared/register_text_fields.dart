import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';

/// Deux champs côte à côte, ou l'un sous l'autre si [stacked].
class FieldPair extends StatelessWidget {
  const FieldPair({
    required this.first,
    required this.second,
    required this.stacked,
    this.spacing = 16,
    super.key,
  });

  final Widget first;
  final Widget second;
  final bool stacked;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          first,
          SizedBox(height: spacing),
          second,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        SizedBox(width: spacing),
        Expanded(child: second),
      ],
    );
  }
}

/// Bouton « afficher / masquer » du mot de passe ([IconButton]).
class PasswordVisibilityButton extends StatelessWidget {
  const PasswordVisibilityButton({
    required this.visible,
    required this.onPressed,
    super.key,
  });

  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: visible ? 'Masquer le mot de passe' : 'Afficher le mot de passe',
      onPressed: onPressed,
      iconSize: 20,
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      ),
    );
  }
}

/// Style d'aide en vert, pour une confirmation sous un champ.
TextStyle? successHelperStyle(BuildContext context) =>
    Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: AppColors.successDeep, fontWeight: FontWeight.w600);

/// Style d'aide en jaune foncé, pour un avertissement sous un champ.
TextStyle? warningHelperStyle(BuildContext context) =>
    Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: AppColors.warningDeep, fontWeight: FontWeight.w600);
