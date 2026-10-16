// Affiche les exemples d’offres, la recherche et les favoris de la visite.
//
// Référence : doc/landing/fichiers/opportunities_section.md.

import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/product_atmosphere.dart';

/// Données d’une offre illustrée : identifiant, intitulé, ville, rythme, compétences et mission.
class OpportunityExample {
  /// Initialise les paramètres de OpportunityExample ; les valeurs par défaut figurent dans la signature.
  const OpportunityExample(
    this.id,
    this.title,
    this.city,
    this.rhythm,
    this.skills,
    this.mission,
  );

  /// Identifiant stable de l’élément.
  final int id;

  /// Titre affiché dans cette composition.
  final String title;

  /// Ville de l’offre illustrée.
  final String city;

  /// Organisation temporelle décrite dans l’offre.
  final String rhythm;

  /// Compétences mentionnées par l’offre.
  final String skills;

  /// Description concrète de la mission.
  final String mission;
}

/// Jeu d’offres utilisé uniquement par l’aperçu interactif.
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

/// Recherche et sélection des offres illustrées, avec favoris de visite.
class OpportunitiesSection extends StatefulWidget {
  /// Initialise les paramètres de OpportunitiesSection ; les valeurs par défaut figurent dans la signature.
  const OpportunitiesSection({super.key});

  /// Crée l’état local associé au widget.
  @override
  State<OpportunitiesSection> createState() => _OpportunitiesSectionState();
}

/// État de OpportunitiesSection ; définit ses données mutables et son rendu.
class _OpportunitiesSectionState extends State<OpportunitiesSection> {
  /// Contrôleur du champ de recherche de ce composant ; libéré dans dispose.
  final search = TextEditingController();

  /// Ensemble des identifiants d’offres enregistrées pendant la visite.
  final saved = <int>{};

  /// Limite les résultats aux offres situées à Paris lorsqu’il est actif.
  bool paris = false;

  /// Limite les résultats aux offres enregistrées.
  bool onlySaved = false;

  /// Texte utilisé pour filtrer la liste d’offres.
  String query = '';

  /// Libère les ressources détenues par cet état avant sa destruction.
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  /// Efface la recherche et les filtres sans vider les favoris.
  void reset() {
    search.clear();
    setState(() {
      paris = false;
      onlySaved = false;
      query = '';
    });
  }

  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) {
    // Éléments qui satisfont les filtres et la recherche.
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
                    // Texte de contexte associé au titre ou au lien.
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
                    // Action appelée lors de l’activation.
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
