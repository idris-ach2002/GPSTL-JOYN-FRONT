import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/profile_completion.dart';

/// Pourcentage de complétion et conseil (« À compléter : … »).
class ProfileCompletionCard extends StatelessWidget {
  const ProfileCompletionCard({required this.completion, super.key});

  final ProfileCompletion completion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final percent = completion.percent;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 58,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: percent / 100),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, value, _) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 6,
                      color: percent == 100
                          ? AppColors.successDeep
                          : AppColors.navy,
                      semanticsLabel: 'Profil complété',
                    ),
                  ),
                  Center(child: Text('$percent%', style: textTheme.titleSmall)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profil complété', style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(completion.tip, style: textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Liste des sections avec leur état (complète ou à compléter).
class ProfileSectionNav extends StatelessWidget {
  const ProfileSectionNav({
    required this.completion,
    required this.onSelected,
    super.key,
  });

  final ProfileCompletion completion;
  final ValueChanged<ProfileSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final section in ProfileSection.values)
          ListTile(
            dense: true,
            onTap: () => onSelected(section),
            leading: Icon(
              completion.isComplete(section)
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: completion.isComplete(section)
                  ? AppColors.successDeep
                  : AppColors.lineDashed,
            ),
            title: Text(section.label),
          ),
      ],
    );
  }
}
