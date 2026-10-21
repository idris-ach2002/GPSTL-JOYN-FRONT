import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/design_system/tokens/app_fonts.dart';

/// En-tête d'une étape : titre + phrase d'explication.
class StepHeading extends StatelessWidget {
  const StepHeading({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 30,
              height: 1.1,
              letterSpacing: -0.9,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: AppColors.slate,
          ),
        ),
      ],
    );
  }
}

/// Groupe de champs : libellé + contenu, avec un complément à droite.
class FieldGroup extends StatelessWidget {
  const FieldGroup({
    required this.label,
    required this.child,
    this.trailing,
    super.key,
  });

  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

/// Deux champs côte à côte, l'un sous l'autre sur petit écran.
class ResponsivePair extends StatelessWidget {
  const ResponsivePair({
    required this.first,
    required this.second,
    this.breakpoint = 520,
    super.key,
  });

  final Widget first;
  final Widget second;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [first, const SizedBox(height: 16), second],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 16),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}
