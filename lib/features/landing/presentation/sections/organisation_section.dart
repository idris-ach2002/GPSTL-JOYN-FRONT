import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/product_atmosphere.dart';
import '../widgets/navigation_symbol.dart';

class OrganisationSection extends StatefulWidget {
  const OrganisationSection({super.key});
  @override
  State<OrganisationSection> createState() => _OrganisationSectionState();
}

class _OrganisationSectionState extends State<OrganisationSection> {
  bool recruiter = true;
  int? expanded;
  static const candidateItems = [
    (
      'Créer son profil avec son CV',
      'Joins ton CV à la création du profil. L’analyse recueille les informations utiles pour présenter ton parcours et tes compétences.',
    ),
    (
      'Consulter les offres correspondantes',
      'Les recommandations présentent les offres qui correspondent à ton profil. Tu peux consulter leurs missions et leurs conditions avant de candidater.',
    ),
    (
      'Retrouver les offres enregistrées',
      'Distingue les postes à relire des candidatures déjà engagées. Enregistrer une offre ne transmet pas de candidature.',
    ),
    (
      'Suivre ses candidatures',
      'Retrouve tes démarches et leur statut pour préparer la suite de ta recherche.',
    ),
  ];
  static const recruiterItems = [
    (
      'Présenter une offre',
      'Décris les missions, les compétences attendues, le contrat, le lieu de travail et l’organisation du poste.',
    ),
    (
      'Consulter les profils recommandés',
      'Examine les informations du profil en lien avec le besoin de recrutement : parcours, expérience et compétences.',
    ),
    (
      'Gérer les candidatures par offre',
      'Retrouve les candidatures associées à chaque poste pour organiser leur consultation et leur suivi.',
    ),
    (
      'Clarifier les attentes',
      'Précise les conditions du poste et réponds aux questions du candidat pendant les échanges.',
    ),
  ];
  void select(bool value) {
    if (value != recruiter) {
      setState(() {
        recruiter = value;
        expanded = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = recruiter ? recruiterItems : candidateItems;
    return EditorialSection(
      tinted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            number: 'CANDIDATS ET RECRUTEURS',
            title: 'Deux usages.\nUn parcours pour chacun.',
            description: 'Choisis ton rôle pour consulter les fonctions qui te concernent.',
          ),
          Wrap(
            spacing: JoynTokens.sm,
            children: [
              Semantics(
                selected: !recruiter,
                child: OutlinedButton(
                  onPressed: () => select(false),
                  child: const Text('CANDIDAT'),
                ),
              ),
              Semantics(
                selected: recruiter,
                child: OutlinedButton(
                  onPressed: () => select(true),
                  child: const Text('RECRUTEUR'),
                ),
              ),
            ],
          ),
          const SizedBox(height: JoynTokens.lg),
          GestureDetector(
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity.abs() >= JoynTokens.swipeVelocity) {
                select(velocity < 0);
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  liveRegion: true,
                  child: ProductSurface(
                    child: Row(
                      children: [
                        NavigationSymbol(
                          kind: recruiter
                              ? NavigationSymbolKind.company
                              : NavigationSymbolKind.profile,
                          active: true,
                        ),
                        const SizedBox(width: JoynTokens.md),
                        Expanded(
                          child: Text(
                            recruiter
                                ? 'Publier une offre.\nSuivre les candidatures.'
                                : 'Présenter son parcours.\nOrganiser sa recherche.',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: JoynTokens.md),
                for (var i = 0; i < items.length; i++) ...[
                  const Divider(),
                  Semantics(
                    expanded: expanded == i,
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: const ButtonStyle(
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: () =>
                            setState(() => expanded = expanded == i ? null : i),
                        child: Text(
                          '${expanded == i ? '−' : '+'} ${items[i].$1}',
                        ),
                      ),
                    ),
                  ),
                  if (expanded == i)
                    Padding(
                      padding: const EdgeInsets.all(JoynTokens.md),
                      child: Text(items[i].$2),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
