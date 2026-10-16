// Présente les services par acteur sans inventer de tarifs ni de conditions commerciales.
//
// Référence : doc/landing/fichiers/plan_comparison_section.md.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/product_atmosphere.dart';
import '../widgets/navigation_symbol.dart';
/// Sélection des services candidat ou entreprise.
class PlanComparisonSection extends StatefulWidget {
  /// Initialise les paramètres de PlanComparisonSection ; les valeurs par défaut figurent dans la signature.
  const PlanComparisonSection({super.key});
  /// Crée l’état local associé au widget.
  @override
  State<PlanComparisonSection> createState() => _PlanComparisonSectionState();
}
/// État de PlanComparisonSection ; définit ses données mutables et son rendu.
class _PlanComparisonSectionState extends State<PlanComparisonSection> {
  /// Sélectionne les services entreprise plutôt que les services candidat.
  bool recruiters = false;
  /// Services présentés pour la recherche de poste.
  static const candidateDetails = [
    ('Profil', 'Présenter son parcours à partir de son CV'),
    ('Recommandations', 'Consulter les offres correspondant à son profil'),
    ('Candidatures', 'Retrouver ses démarches et leur statut'),
  ];
  /// Services présentés pour le recrutement en entreprise.
  static const companyDetails = [
    ('Offres', 'Présenter les missions et les attentes du poste'),
    ('Profils', 'Consulter les profils recommandés'),
    ('Candidatures', 'Organiser le suivi des candidatures par offre'),
  ];
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => EditorialSection(tinted: true,child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
    const SectionHeading(number: 'LES SERVICES JOYN',title: 'Un espace pour chercher.\nUn espace pour recruter.',description: 'Consulte les services correspondant à ton usage.'),
    Wrap(spacing: JoynTokens.sm,runSpacing: JoynTokens.sm,children: [
      Semantics(selected: !recruiters,child: OutlinedButton(onPressed: () => setState(() => recruiters=false),child: const Text('CANDIDAT'))),
      Semantics(selected: recruiters,child: OutlinedButton(onPressed: () => setState(() => recruiters=true),child: const Text('ENTREPRISE'))),
    ]),const SizedBox(height: JoynTokens.lg),
    AnimatedSwitcher(duration: MediaQuery.disableAnimationsOf(context) ? JoynTokens.instant : JoynTokens.menuDuration,
      child: ProductSurface(key: ValueKey(recruiters),accent: true,child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
        NavigationSymbol(kind: recruiters ? NavigationSymbolKind.companyPlan : NavigationSymbolKind.candidatePlan,active: true),
        const SizedBox(height: JoynTokens.md),
        Text(recruiters ? 'Pour le recrutement en entreprise' : 'Pour ta recherche de poste',style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: JoynTokens.md),
        for(final item in recruiters ? companyDetails : candidateDetails) InformationRow(label: item.$1,value: item.$2),
        const SizedBox(height: JoynTokens.md),
        TextButton(onPressed: () => context.go('/assistance'),child: const Text('UNE QUESTION SUR LES FORMULES ? →')),
      ]))),
  ]));
}
