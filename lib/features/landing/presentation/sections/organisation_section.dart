// Présente les fonctions candidat ou recruteur dans un même espace sélectionnable.
//
// Référence : doc/landing/fichiers/organisation_section.md.

import 'package:flutter/material.dart';
import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/product_atmosphere.dart';
import '../widgets/navigation_symbol.dart';
/// Bloc commun qui distingue les usages candidat et recruteur.
class OrganisationSection extends StatefulWidget {
  /// Initialise les paramètres de OrganisationSection ; les valeurs par défaut figurent dans la signature.
  const OrganisationSection({super.key});
  /// Crée l’état local associé au widget.
  @override
  State<OrganisationSection> createState() => _OrganisationSectionState();
}
/// État de OrganisationSection ; définit ses données mutables et son rendu.
class _OrganisationSectionState extends State<OrganisationSection> {
  /// Sélectionne le rôle recruteur ou son portrait selon le composant.
  bool recruiter=true;
  /// Indice du détail ouvert, ou état ouvert/fermé selon le composant.
  int? expanded;
  /// Fonctions et descriptions propres au parcours candidat.
  static const candidateItems=[
    ('Créer son profil avec son CV','Joins ton CV à la création du profil. L’analyse recueille les informations utiles pour présenter ton parcours et tes compétences.'),
    ('Consulter les offres correspondantes','Les recommandations présentent les offres qui correspondent à ton profil. Tu peux consulter leurs missions et leurs conditions avant de candidater.'),
    ('Retrouver les offres enregistrées','Distingue les postes à relire des candidatures déjà engagées. Enregistrer une offre ne transmet pas de candidature.'),
    ('Suivre ses candidatures','Retrouve tes démarches et leur statut pour préparer la suite de ta recherche.'),
  ];
  /// Fonctions et descriptions propres au parcours recruteur.
  static const recruiterItems=[
    ('Présenter une offre','Décris les missions, les compétences attendues, le contrat, le lieu de travail et l’organisation du poste.'),
    ('Consulter les profils recommandés','Examine les informations du profil en lien avec le besoin de recrutement : parcours, expérience et compétences.'),
    ('Gérer les candidatures par offre','Retrouve les candidatures associées à chaque poste pour organiser leur consultation et leur suivi.'),
    ('Clarifier les attentes','Précise les conditions du poste et réponds aux questions du candidat pendant les échanges.'),
  ];
  /// Change la sélection en respectant les limites du contenu.
  void select(bool value) { if(value!=recruiter) { setState(() { recruiter=value;expanded=null; }); } }
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) {
    // Liste de contenus correspondant à l’acteur ou à la sélection courante.
    final items=recruiter ? recruiterItems : candidateItems;
    return EditorialSection(tinted: true,child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
      const SectionHeading(number:'CANDIDATS ET RECRUTEURS',title:'Deux usages.\nUn parcours pour chacun.',description:'Choisis ton rôle pour consulter les fonctions qui te concernent.'),
      Wrap(spacing: JoynTokens.sm,children: [
        Semantics(selected: !recruiter,child: OutlinedButton(onPressed: () => select(false),child: const Text('CANDIDAT'))),
        Semantics(selected: recruiter,child: OutlinedButton(onPressed: () => select(true),child: const Text('RECRUTEUR'))),
      ]),const SizedBox(height: JoynTokens.lg),
      GestureDetector(onHorizontalDragEnd: (details) {
        // Vitesse horizontale du geste, utilisée pour choisir le rôle affiché.
        final velocity=details.primaryVelocity ?? 0;
        if(velocity.abs()>=JoynTokens.swipeVelocity) { select(velocity<0); }
      },child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
        Semantics(liveRegion: true,child: ProductSurface(child: Row(children: [
          NavigationSymbol(kind: recruiter ? NavigationSymbolKind.company : NavigationSymbolKind.profile,active: true),const SizedBox(width: JoynTokens.md),
          Expanded(child: Text(recruiter ? 'Publier une offre.\nSuivre les candidatures.' : 'Présenter son parcours.\nOrganiser sa recherche.',style: Theme.of(context).textTheme.headlineSmall)),
        ]))),const SizedBox(height: JoynTokens.md),
        for(var i=0;i<items.length;i++) ...[
          const Divider(),Semantics(expanded: expanded==i,child: SizedBox(width: double.infinity,child: TextButton(
            style: const ButtonStyle(alignment: Alignment.centerLeft),onPressed: () => setState(() => expanded=expanded==i ? null : i),child: Text('${expanded==i ? '−' : '+'} ${items[i].$1}')))),
          if(expanded==i) Padding(padding: const EdgeInsets.all(JoynTokens.md),child: Text(items[i].$2)),
        ],
      ])),
    ]));
  }
}
