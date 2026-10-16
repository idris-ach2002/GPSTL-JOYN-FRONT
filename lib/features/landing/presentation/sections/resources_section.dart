import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';

class ResourcesSection extends StatelessWidget {
  const ResourcesSection({super.key, required this.onOpen});
  final ValueChanged<String> onOpen;
  @override
  Widget build(BuildContext context) => EditorialSection(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          number: '15 / RESSOURCES',
          title: 'Des repères pour\npréparer la suite.',
          description: 'Des conseils pour présenter son parcours, comprendre les recommandations et préparer un échange.',
        ),
        for (final item in const [
          (
            '01',
            'Présenter son profil',
            'Relier une compétence à une réalisation, expliquer sa contribution et rendre ses contraintes lisibles.',
            'guide-profil',
          ),
          (
            '02',
            'Lire un matching',
            'Comprendre l’analyse du CV et les offres correspondant au profil.',
            'guide-matching',
          ),
          (
            '03',
            'Préparer un entretien',
            'Raconter un projet, choisir une difficulté à expliquer et préparer ses questions.',
            'guide-entretien',
          ),
        ]) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: JoynTokens.md),
            child: EditorialSplit(
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.$1, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: JoynTokens.sm),
                  Text(
                    item.$2,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.$3),
                  const SizedBox(height: JoynTokens.md),
                  OutlinedButton(
                    onPressed: () => onOpen(item.$4),
                    child: const Text('LIRE LE GUIDE →'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
