import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/journey_preview.dart';

class JourneyCarousel extends StatefulWidget {
  const JourneyCarousel({super.key});
  @override
  State<JourneyCarousel> createState() => _JourneyCarouselState();
}

class _JourneyCarouselState extends State<JourneyCarousel> {
  final PageController controller = PageController();
  int active = 0;
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
  void select(int index) {
    if (index < 0 || index >= slides.length) {
      return;
    }
    controller.jumpToPage(index);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
          select(active - 1),
      const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
          select(active + 1),
    },
    child: EditorialSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            number: '04 / LE PARCOURS CANDIDAT',
            title: 'Du profil au premier échange.',
            description: 'Trois étapes pour préparer son profil et comprendre les offres proposées.',
          ),
          Wrap(
            spacing: JoynTokens.xs,
            runSpacing: JoynTokens.xs,
            children: [
              for (var i = 0; i < slides.length; i++)
                Semantics(
                  selected: active == i,
                  child: TextButton(
                    onPressed: () => select(i),
                    child: Text(
                      '${i + 1} / ${['PROFIL', 'CRITÈRES', 'ÉCHANGE'][i]}${active == i ? ' —' : ''}',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: JoynTokens.md),
          LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              height:
                  constraints.maxWidth < JoynTokens.tablet - JoynTokens.xl * 2
                  ? JoynTokens.carouselCompactHeight
                  : JoynTokens.carouselHeight,
              child: PageView.builder(
                controller: controller,
                itemCount: slides.length,
                onPageChanged: (index) => setState(() => active = index),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Semantics(
                    label: 'Étape ${index + 1} sur ${slides.length}',
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(JoynTokens.md),
                      child: EditorialSplit(
                        leading: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slide.title,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: JoynTokens.md),
                            Text(slide.text),
                          ],
                        ),
                        trailing: JourneyPreview(stage: index == 2 ? 3 : index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: JoynTokens.md),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: JoynTokens.md,
            runSpacing: JoynTokens.sm,
            children: [
              OutlinedButton(
                onPressed: active > 0 ? () => select(active - 1) : null,
                child: const Text('PRÉCÉDENT'),
              ),
              Semantics(
                liveRegion: true,
                child: Text(
                  '${active + 1} / ${slides.length}',
                  key: const ValueKey('carousel-position'),
                ),
              ),
              OutlinedButton(
                onPressed: active < slides.length - 1
                    ? () => select(active + 1)
                    : null,
                child: const Text('SUIVANT'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
