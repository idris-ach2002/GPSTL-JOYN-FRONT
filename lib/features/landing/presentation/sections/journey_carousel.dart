// Parcours complet, sans commandes affichées ni défilement vertical interne.
import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/journey_preview.dart';
import '../widgets/carousel_navigation.dart';

/// Trois étapes consultables au glisser, au défilement horizontal et au clavier.
class JourneyCarousel extends StatelessWidget {
  /// Présente les trois étapes sans contrôles superposés.
  const JourneyCarousel({super.key});

  /// Titres et explications associés aux aperçus de chaque étape.
  static const slides = [
    (
      title: 'Précise ce qui compte.',
      text: 'Compétences, mobilité, rythme : rends tes contraintes lisibles avant de regarder les offres.',
      rows: [
        ('Compétences', 'Dart, Flutter'),
        ('Mobilité', 'Paris'),
        ('Rythme', '3 jours en entreprise'),
      ],
    ),
    (
      title: 'Lis les points communs.',
      text: 'Consulte les missions, les conditions du poste et les correspondances avec ton profil.',
      rows: [
        ('Même localisation', 'Paris'),
        ('Même rythme', '3 jours en entreprise'),
        ('Compétences communes', 'Dart et Flutter'),
      ],
    ),
    (
      title: 'Exprime ton intérêt.',
      text: 'Le parcours présenté prévoit une mise en relation quand le candidat et l’entreprise expriment tous deux leur intérêt.',
      rows: [
        ('Candidat', 'Intéressé'),
        ('Entreprise', 'Intéressée'),
        ('Étape suivante', 'Premier échange'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) => EditorialSection(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          number: '04 / LE PARCOURS CANDIDAT',
          title: 'Du profil au premier échange.',
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < JoynTokens.tablet - JoynTokens.xl * 2;
            return NaturalCarousel(
              id: 'carousel',
              items: [
                for (var i = 0; i < slides.length; i++)
                  Semantics(
                    label: 'Étape ${i + 1} sur ${slides.length}',
                    child: compact
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slides[i].title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge,
                              ),
                              const SizedBox(height: JoynTokens.md),
                              Text(slides[i].text),
                              const SizedBox(height: JoynTokens.lg),
                              JourneyPreview(stage: i == 2 ? 3 : i),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      slides[i].title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge,
                                    ),
                                    const SizedBox(height: JoynTokens.md),
                                    Text(slides[i].text),
                                  ],
                                ),
                              ),
                              const SizedBox(width: JoynTokens.xl),
                              Expanded(
                                child: JourneyPreview(stage: i == 2 ? 3 : i),
                              ),
                            ],
                          ),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );
}
