// Bénéfices JOYN par acteur, réunis dans un même espace de présentation.
import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/product_atmosphere.dart';
import '../widgets/navigation_symbol.dart';

/// Le rôle initial est fourni par la route ou la navigation, puis reste sélectionnable.
class OrganisationSection extends StatefulWidget {
  const OrganisationSection({super.key, this.initialRecruiter = false});
  final bool initialRecruiter;
  @override
  State<OrganisationSection> createState() => _OrganisationSectionState();
}

class _OrganisationSectionState extends State<OrganisationSection> {
  late bool recruiter = widget.initialRecruiter;
  int selected = 0;
  static const candidateBenefits = [
    (
      'Un profil à partir du CV',
      'Présenter son parcours une seule fois',
      'Le CV joint à la création du profil est analysé pour en recueillir les informations utiles. Le profil présente l’expérience et les compétences au recruteur.',
      'PARCOURS → PROFIL',
      NavigationSymbolKind.cv,
    ),
    (
      'Des offres correspondantes',
      'Lire des postes en rapport avec son profil',
      'La sélection présente les offres correspondant au profil candidat. Les missions et conditions restent consultables pour décider de poursuivre la démarche.',
      'PROFIL → OFFRES',
      NavigationSymbolKind.matching,
    ),
    (
      'Des favoris distincts des candidatures',
      'Garder un poste à relire sans candidater',
      'Une offre enregistrée reste un repère personnel. Une candidature constitue une démarche différente : les deux listes servent des usages distincts.',
      'À RELIRE / CANDIDATÉ',
      NavigationSymbolKind.favorites,
    ),
    (
      'Un suivi au même endroit',
      'Retrouver les démarches et préparer la suite',
      'Le statut et le poste concerné replacent chaque candidature dans son contexte. Les outils d’organisation dépendent de la formule choisie.',
      'CANDIDATURE → SUIVI',
      NavigationSymbolKind.tracking,
    ),
    (
      'Un intérêt partagé',
      'Distinguer une correspondance d’un échange',
      'Une offre correspondante n’est pas une promesse d’embauche. L’intérêt du candidat et celui du recruteur sont deux décisions distinctes avant la conversation.',
      'DEUX INTÉRÊTS → ÉCHANGE',
      NavigationSymbolKind.reciprocal,
    ),
  ];
  static const recruiterBenefits = [
    (
      'Une offre structurée',
      'Rendre les attentes du poste lisibles',
      'Décrire les missions, les compétences, le contrat et l’organisation du travail permet au candidat de comprendre le besoin avant de candidater.',
      'BESOIN → OFFRE',
      NavigationSymbolKind.publish,
    ),
    (
      'Des profils recommandés',
      'Examiner le parcours dans le contexte du poste',
      'Consulter les compétences et l’expérience avec les attentes de l’offre donne un cadre de lecture au recrutement.',
      'OFFRE → PROFILS',
      NavigationSymbolKind.inspectProfile,
    ),
    (
      'Les candidatures par offre',
      'Éviter de mélanger les recrutements',
      'Chaque candidature est associée au poste concerné. Le recruteur retrouve le profil et l’état de la démarche dans ce même contexte.',
      'OFFRE → CANDIDATURES',
      NavigationSymbolKind.inbox,
    ),
    (
      'Une organisation partagée',
      'Répartir la gestion du recrutement',
      'La formule Membre premium prévoit plusieurs comptes, des rôles et l’attribution des candidatures pour organiser le travail entre recruteurs.',
      'RÔLES → ATTRIBUTIONS',
      NavigationSymbolKind.company,
    ),
    (
      'Une vue de pilotage',
      'Suivre l’activité des offres',
      'Le tableau de bord partagé et l’export de suivi de Membre premium rassemblent les informations utiles à la gestion des recrutements.',
      'SUIVI → PILOTAGE',
      NavigationSymbolKind.chart,
    ),
  ];

  @override
  void didUpdateWidget(covariant OrganisationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRecruiter != widget.initialRecruiter) {
      recruiter = widget.initialRecruiter;
      selected = 0;
    }
  }

  void selectRole(bool value) {
    if (value != recruiter) {
      setState(() {
        recruiter = value;
        selected = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final benefits = recruiter ? recruiterBenefits : candidateBenefits;
    final benefit = benefits[selected];
    final theme = Theme.of(context).textTheme;
    return ProductAtmosphere(
      child: EditorialSection(
        transparent: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CE QUE JOYN APPORTE',
              style: theme.labelLarge?.copyWith(color: JoynTokens.blue),
            ),
            const SizedBox(height: JoynTokens.md),
            Text(
              recruiter
                  ? 'Recruter, de l’offre\nà la candidature.'
                  : 'Chercher un poste.\nGarder le fil.',
              style: theme.displaySmall?.copyWith(color: JoynTokens.paper),
            ),
            const SizedBox(height: JoynTokens.md),
            Text(
              recruiter
                  ? 'Décrire le besoin, consulter les profils et organiser les démarches autour de chaque offre.'
                  : 'Présenter son parcours, consulter des offres correspondantes et retrouver chaque candidature.',
              style: theme.bodyLarge?.copyWith(color: JoynTokens.paper),
            ),
            const SizedBox(height: JoynTokens.lg),
            Wrap(
              spacing: JoynTokens.sm,
              runSpacing: JoynTokens.sm,
              children: [
                for (final role in [false, true])
                  Semantics(
                    selected: recruiter == role,
                    child: OutlinedButton(
                      key: ValueKey(
                        role ? 'benefits-recruiter' : 'benefits-candidate',
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: recruiter == role
                            ? JoynTokens.orange
                            : JoynTokens.paper,
                        foregroundColor: JoynTokens.ink,
                      ),
                      onPressed: () => selectRole(role),
                      child: Text(role ? 'RECRUTEUR' : 'CANDIDAT'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: JoynTokens.lg),
            GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity.abs() >= JoynTokens.swipeVelocity) {
                  selectRole(velocity < 0);
                }
              },
              child: ProductSurface(
                child: EditorialSplit(
                  leading: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < benefits.length; i++) ...[
                        const Divider(),
                        Semantics(
                          selected: selected == i,
                          child: SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              key: ValueKey('benefit-$i'),
                              style: const ButtonStyle(
                                alignment: Alignment.centerLeft,
                              ),
                              onPressed: () => setState(() => selected = i),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: JoynTokens.sm,
                                ),
                                child: Row(
                                  children: [
                                    NavigationSymbol(
                                      kind: benefits[i].$5,
                                      active: selected == i,
                                      size: JoynTokens.smallSymbol,
                                    ),
                                    const SizedBox(width: JoynTokens.sm),
                                    Expanded(child: Text(benefits[i].$1)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: Semantics(
                    liveRegion: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NavigationSymbol(kind: benefit.$5, active: true),
                        const SizedBox(height: JoynTokens.md),
                        Text(benefit.$2, style: theme.headlineLarge),
                        const SizedBox(height: JoynTokens.md),
                        Text(benefit.$3),
                        const SizedBox(height: JoynTokens.lg),
                        const Divider(),
                        const SizedBox(height: JoynTokens.md),
                        Text(benefit.$4, style: theme.labelLarge),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
