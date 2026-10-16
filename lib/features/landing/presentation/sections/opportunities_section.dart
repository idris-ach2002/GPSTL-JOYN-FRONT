import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/product_atmosphere.dart';

class OpportunityExample {
  const OpportunityExample(
    this.id,
    this.title,
    this.city,
    this.rhythm,
    this.skills,
    this.mission,
  );
  final int id;
  final String title;
  final String city;
  final String rhythm;
  final String skills;
  final String mission;
}

const opportunityExamples = [
  OpportunityExample(
    1,
    'Développement Flutter',
    'Paris',
    '3 jours en entreprise',
    'Dart · Flutter',
    'Construire et améliorer une interface de suivi.',
  ),
  OpportunityExample(
    2,
    'Interface web',
    'Lyon',
    '1 semaine sur 2',
    'HTML · CSS · JavaScript',
    'Rendre un parcours de recherche plus lisible.',
  ),
  OpportunityExample(
    3,
    'Qualité logicielle',
    'Nantes',
    '3 jours en entreprise',
    'Tests · documentation',
    'Vérifier des scénarios et rendre les résultats compréhensibles.',
  ),
  OpportunityExample(
    4,
    'Conception produit',
    'Paris',
    '1 semaine sur 2',
    'Prototypage · entretiens',
    'Comprendre un besoin et proposer un parcours testable.',
  ),
];

class OpportunitiesSection extends StatefulWidget {
  const OpportunitiesSection({super.key});
  @override
  State<OpportunitiesSection> createState() => _OpportunitiesSectionState();
}

class _OpportunitiesSectionState extends State<OpportunitiesSection> {
  final search = TextEditingController();
  final saved = <int>{};
  bool paris = false;
  bool onlySaved = false;
  String query = '';
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void reset() {
    search.clear();
    setState(() {
      paris = false;
      onlySaved = false;
      query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = opportunityExamples
        .where(
          (offer) =>
              (!paris || offer.city == 'Paris') &&
              (!onlySaved || saved.contains(offer.id)) &&
              '${offer.title} ${offer.skills} ${offer.city}'
                  .toLowerCase()
                  .contains(query.toLowerCase().trim()),
        )
        .toList();
    return EditorialSection(
      tinted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            number: '08 / EXPLORER LES OPPORTUNITÉS',
            title: 'Garder les offres\nqui méritent ton attention.',
            description: 'Exemples d’offres : recherche dans la liste et enregistre les postes que tu souhaites retrouver pendant ta visite.',
          ),
          TextField(
            controller: search,
            onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(
              labelText: 'Rechercher un métier, une compétence ou une ville',
            ),
          ),
          const SizedBox(height: JoynTokens.md),
          Wrap(
            spacing: JoynTokens.sm,
            runSpacing: JoynTokens.xs,
            children: [
              Semantics(
                toggled: paris,
                child: OutlinedButton(
                  onPressed: () => setState(() => paris = !paris),
                  child: Text(paris ? 'PARIS UNIQUEMENT —' : 'FILTRER PARIS'),
                ),
              ),
              Semantics(
                toggled: onlySaved,
                child: OutlinedButton(
                  onPressed: () => setState(() => onlySaved = !onlySaved),
                  child: Text(
                    'FAVORIS (${saved.length})${onlySaved ? ' —' : ''}',
                  ),
                ),
              ),
              TextButton(
                onPressed: reset,
                child: const Text('RÉINITIALISER LES FILTRES'),
              ),
            ],
          ),
          const SizedBox(height: JoynTokens.md),
          Semantics(
            liveRegion: true,
            child: Text(
              '${results.length} exemple(s) d’offre affiché(s)',
              key: const ValueKey('offer-count'),
            ),
          ),
          const SizedBox(height: JoynTokens.lg),
          if (results.isEmpty)
            ProductSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aucune offre dans cette sélection.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: JoynTokens.sm),
                  const Text(
                    'Essaie une autre recherche, désactive Paris ou enregistre une offre avant de filtrer les favoris.',
                  ),
                  const SizedBox(height: JoynTokens.md),
                  FilledButton(
                    onPressed: reset,
                    child: const Text('REVOIR LES EXEMPLES'),
                  ),
                ],
              ),
            ),
          for (final offer in results)
            Padding(
              padding: const EdgeInsets.only(bottom: JoynTokens.md),
              child: ProductSurface(
                accent: saved.contains(offer.id),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final description = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: JoynTokens.sm),
                        Text('${offer.city} · ${offer.rhythm}'),
                        const SizedBox(height: JoynTokens.sm),
                        Text(offer.mission),
                        const SizedBox(height: JoynTokens.sm),
                        Text('À mobiliser : ${offer.skills}'),
                      ],
                    );
                    final action = Semantics(
                      toggled: saved.contains(offer.id),
                      child: OutlinedButton(
                        key: ValueKey('save-offer-${offer.id}'),
                        onPressed: () => setState(() {
                          if (!saved.add(offer.id)) {
                            saved.remove(offer.id);
                          }
                        }),
                        child: Text(
                          saved.contains(offer.id)
                              ? 'RETIRER DES FAVORIS'
                              : 'ENREGISTRER',
                        ),
                      ),
                    );
                    if (constraints.maxWidth < JoynTokens.mobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          description,
                          const SizedBox(height: JoynTokens.md),
                          action,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: description),
                        const SizedBox(width: JoynTokens.md),
                        action,
                      ],
                    );
                  },
                ),
              ),
            ),
          const Text(
            'Les favoris de cet aperçu sont conservés pendant la visite.',
          ),
        ],
      ),
    );
  }
}
