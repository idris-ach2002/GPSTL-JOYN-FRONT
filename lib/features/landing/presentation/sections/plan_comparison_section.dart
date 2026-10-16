import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/product_atmosphere.dart';
import '../widgets/navigation_symbol.dart';

/// Presents confirmed product uses without inventing prices or paid entitlements.
class PlanComparisonSection extends StatefulWidget {
  const PlanComparisonSection({super.key});
  @override
  State<PlanComparisonSection> createState() => _PlanComparisonSectionState();
}

class _PlanComparisonSectionState extends State<PlanComparisonSection> {
  bool recruiters = false;
  static const candidateDetails = [
    ('Profil', 'Présenter son parcours à partir de son CV'),
    ('Recommandations', 'Consulter les offres correspondant à son profil'),
    ('Candidatures', 'Retrouver ses démarches et leur statut'),
  ];
  static const companyDetails = [
    ('Offres', 'Présenter les missions et les attentes du poste'),
    ('Profils', 'Consulter les profils recommandés'),
    ('Candidatures', 'Organiser le suivi des candidatures par offre'),
  ];
  @override
  Widget build(BuildContext context) => EditorialSection(
    tinted: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          number: 'LES SERVICES JOYN',
          title: 'Un espace pour chercher.\nUn espace pour recruter.',
          description: 'Consulte les services correspondant à ton usage.',
        ),
        Wrap(
          spacing: JoynTokens.sm,
          runSpacing: JoynTokens.sm,
          children: [
            Semantics(
              selected: !recruiters,
              child: OutlinedButton(
                onPressed: () => setState(() => recruiters = false),
                child: const Text('CANDIDAT'),
              ),
            ),
            Semantics(
              selected: recruiters,
              child: OutlinedButton(
                onPressed: () => setState(() => recruiters = true),
                child: const Text('ENTREPRISE'),
              ),
            ),
          ],
        ),
        const SizedBox(height: JoynTokens.lg),
        AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? JoynTokens.instant
              : JoynTokens.menuDuration,
          child: ProductSurface(
            key: ValueKey(recruiters),
            accent: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NavigationSymbol(
                  kind: recruiters
                      ? NavigationSymbolKind.companyPlan
                      : NavigationSymbolKind.candidatePlan,
                  active: true,
                ),
                const SizedBox(height: JoynTokens.md),
                Text(
                  recruiters
                      ? 'Pour le recrutement en entreprise'
                      : 'Pour ta recherche de poste',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: JoynTokens.md),
                for (final item
                    in recruiters ? companyDetails : candidateDetails)
                  InformationRow(label: item.$1, value: item.$2),
                const SizedBox(height: JoynTokens.md),
                TextButton(
                  onPressed: () => context.go('/assistance'),
                  child: const Text('UNE QUESTION SUR LES FORMULES ? →'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
