import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/components/joyn_logo.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';

/// Barre du haut de l'onboarding : logo, contenu central optionnel (la
/// progression), action à droite. Sur petit écran, le centre passe dessous.
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
    final center = this.center;

    final logo = Tooltip(
      message: "Retour à l'accueil",
      child: InkWell(
        onTap: () => context.go(AppRoutes.landing),
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
          if (center != null) ...[const SizedBox(height: 12), center],
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
                : Align(child: center),
          ),
          const SizedBox(width: 20),
          trailing,
        ],
      );
    }

    return Material(
      color: AppColors.surface,
      shape: const Border(bottom: BorderSide(color: AppColors.lineSoft)),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Progression « Étape 2 / 5 » ([LinearProgressIndicator]).
class StepProgress extends StatelessWidget {
  const StepProgress({
    required this.step,
    required this.stepCount,
    this.maxWidth = 420,
    super.key,
  });

  final int step;
  final int stepCount;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        children: [
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: step / stepCount),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                borderRadius: BorderRadius.circular(99),
                semanticsLabel: 'Progression du profil',
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Étape $step / $stepCount',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
