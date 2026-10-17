// Formules mensuelles et comparaison horizontale des prestations.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../../domain/subscription_plans.dart';
import '../widgets/carousel_navigation.dart';
import '../widgets/editorial_layout.dart';

/// Catalogue candidat/entreprise avec cartes consultables au geste et au clavier.
class PlanComparisonSection extends StatefulWidget {
  const PlanComparisonSection({super.key, this.initialCompany = false});
  final bool initialCompany;
  @override
  State<PlanComparisonSection> createState() => _PlanComparisonSectionState();
}

class _PlanComparisonSectionState extends State<PlanComparisonSection> {
  late bool company = widget.initialCompany;
  @override
  void didUpdateWidget(covariant PlanComparisonSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCompany != widget.initialCompany) {
      company = widget.initialCompany;
    }
  }

  @override
  Widget build(BuildContext context) => EditorialSection(
    tinted: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          number: 'FORMULES',
          title: 'Compare les accès.\nChoisis ta formule.',
          description: 'Compare les accès, les outils de suivi et les possibilités d’administration. Tarifs mensuels en euros.',
        ),
        Wrap(
          spacing: JoynTokens.sm,
          runSpacing: JoynTokens.xs,
          children: [
            Semantics(
              selected: !company,
              child: OutlinedButton(
                key: const ValueKey('plans-candidate'),
                onPressed: () => setState(() => company = false),
                child: Text('CANDIDAT${!company ? ' —' : ''}'),
              ),
            ),
            Semantics(
              selected: company,
              child: OutlinedButton(
                key: const ValueKey('plans-company'),
                onPressed: () => setState(() => company = true),
                child: Text('ENTREPRISE${company ? ' —' : ''}'),
              ),
            ),
          ],
        ),
        const SizedBox(height: JoynTokens.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final fraction = constraints.maxWidth < JoynTokens.mobile
                ? JoynTokens.planMobileFraction
                : constraints.maxWidth < JoynTokens.tablet
                ? JoynTokens.planTabletFraction
                : JoynTokens.planDesktopFraction;
            return _PlanDeck(
              key: ValueKey('$company-$fraction'),
              plans: company ? companyPlans : candidatePlans,
              viewportFraction: fraction,
            );
          },
        ),
      ],
    ),
  );
}

/// La sélection visuelle suit le carrousel ; les cartes gardent leur hauteur naturelle.
class _PlanDeck extends StatefulWidget {
  const _PlanDeck({
    super.key,
    required this.plans,
    required this.viewportFraction,
  });
  final List<SubscriptionPlan> plans;
  final double viewportFraction;
  @override
  State<_PlanDeck> createState() => _PlanDeckState();
}

class _PlanDeckState extends State<_PlanDeck> {
  int active = 0;
  @override
  Widget build(BuildContext context) => NaturalCarousel(
    id: 'plans',
    viewportFraction: widget.viewportFraction,
    onChanged: (index) => setState(() => active = index),
    items: [
      for (var i = 0; i < widget.plans.length; i++)
        _PlanCard(plan: widget.plans[i], order: i + 1, active: active == i),
    ],
  );
}

/// Carte de prestations ; le détail récapitule la formule sans lancer de paiement.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.order,
    required this.active,
  });
  final SubscriptionPlan plan;
  final int order;
  final bool active;

  void showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: JoynTokens.paper,
      shape: JoynTokens.shape,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              JoynTokens.md,
              JoynTokens.sm,
              JoynTokens.md,
              JoynTokens.md + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text('${plan.price}${plan.monthlyCents > 0 ? ' / mois' : ''}'),
                const SizedBox(height: JoynTokens.md),
                for (final feature in plan.features)
                  InformationRow(label: feature.$1, value: feature.$2),
                const SizedBox(height: JoynTokens.md),
                FilledButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    context.go('/connexion');
                  },
                  child: const Text('ACCÉDER À MON ESPACE'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: MediaQuery.disableAnimationsOf(context)
        ? JoynTokens.instant
        : JoynTokens.menuDuration,
    key: ValueKey(plan.id),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: JoynTokens.paper,
      borderRadius: BorderRadius.circular(JoynTokens.radius),
      border: Border.all(
        color: active ? JoynTokens.ink : JoynTokens.line,
        width: JoynTokens.hairline,
      ),
    ),
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: () => showDetails(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: JoynTokens.xs,
              color: active ? JoynTokens.orange : JoynTokens.ink,
            ),
            Padding(
              padding: const EdgeInsets.all(JoynTokens.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order.toString().padLeft(2, '0')} / ${plan.name.toUpperCase()}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: JoynTokens.sm),
                  Text(
                    plan.price,
                    key: ValueKey('${plan.id}-price'),
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  Text(plan.monthlyCents == 0 ? 'Accès gratuit' : 'par mois'),
                  const SizedBox(height: JoynTokens.md),
                  Text(
                    plan.intention,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: JoynTokens.md),
                  for (final feature in plan.features) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: JoynTokens.xs,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature.$1,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: JoynTokens.xs),
                          Text(feature.$2),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
