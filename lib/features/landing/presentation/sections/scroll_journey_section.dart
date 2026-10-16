import 'package:flutter/material.dart';

import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/journey_preview.dart';
import 'journey_carousel.dart';

/// Pins inside its own document space. Normal browser scrolling is preserved.
class ScrollJourneySection extends StatefulWidget {
  const ScrollJourneySection({
    super.key,
    required this.controller,
    this.topInset = JoynTokens.navHeight,
  });
  final ScrollController controller;
  final double topInset;
  @override
  State<ScrollJourneySection> createState() => _ScrollJourneySectionState();
}

class _ScrollJourneySectionState extends State<ScrollJourneySection> {
  double progress = 0;
  double pin = 0;
  final storyKey = GlobalKey();
  static const steps = [
    (
      'Ton profil',
      'Tes compétences prennent du sens avec une réalisation et ton contexte.',
    ),
    (
      'Les critères',
      'Lieu, rythme et compétence : les points communs et les écarts restent visibles.',
    ),
    (
      'Les deux intérêts',
      'Ton intérêt et celui de l’entreprise sont présentés séparément.',
    ),
    (
      'Le premier échange',
      'Un projet à raconter. Des attentes et des questions à partager.',
    ),
  ];
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(update);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => update());
  }

  @override
  void didUpdateWidget(covariant ScrollJourneySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topInset != widget.topInset) {
      WidgetsBinding.instance.addPostFrameCallback((_) => update());
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(update);
      widget.controller.addListener(update);
    }
  }

  void update() {
    if (!mounted) {
      return;
    }
    final box = storyKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return;
    }
    final viewport = MediaQuery.sizeOf(context).height - widget.topInset;
    final travel = viewport * 2;
    final offset = (widget.topInset - box.localToGlobal(Offset.zero).dy)
        .clamp(0.0, travel)
        .toDouble();
    final next = offset / travel;
    if ((offset - pin).abs() > .1 || (next - progress).abs() > .001) {
      setState(() {
        pin = offset;
        progress = next;
      });
    }
  }

  void select(int index, double travel) {
    final box = storyKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !widget.controller.hasClients) {
      return;
    }
    final start =
        widget.controller.offset +
        box.localToGlobal(Offset.zero).dy -
        widget.topInset;
    final destination = (start + travel * index / (steps.length - 1))
        .clamp(0.0, widget.controller.position.maxScrollExtent)
        .toDouble();
    widget.controller.animateTo(
      destination,
      duration: JoynTokens.duration,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final screen = MediaQuery.sizeOf(context);
      if (constraints.maxWidth < JoynTokens.tablet ||
          screen.height - widget.topInset <
              JoynTokens.stickySceneHeight - JoynTokens.navHeight ||
          MediaQuery.textScalerOf(context).scale(JoynTokens.body) >
              JoynTokens.body * 1.1 ||
          MediaQuery.disableAnimationsOf(context)) {
        return const JourneyCarousel();
      }
      final viewport = screen.height - widget.topInset;
      final stage = (progress * steps.length)
          .floor()
          .clamp(0, steps.length - 1)
          .toInt();
      return SizedBox(
        key: storyKey,
        height: viewport * 3,
        child: Stack(
          children: [
            Positioned(
              top: pin,
              left: 0,
              right: 0,
              height: viewport,
              child: ColoredBox(
                color: JoynTokens.paper,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: JoynTokens.xl,
                      vertical: JoynTokens.md,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: JoynTokens.content,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeading(
                              number: '04 / LE PARCOURS',
                              title: 'Du profil au premier échange.',
                            ),
                            EditorialSplit(
                              leading: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var i = 0; i < steps.length; i++) ...[
                                    const Divider(),
                                    SizedBox(
                                      width: double.infinity,
                                      child: TextButton(
                                        style: const ButtonStyle(
                                          alignment: Alignment.centerLeft,
                                        ),
                                        onPressed: () =>
                                            select(i, viewport * 2),
                                        child: Text(
                                          '${i + 1} / ${steps[i].$1}${stage == i ? ' —' : ''}',
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: JoynTokens.md),
                                  Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      steps[stage].$2,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                  ),
                                  const SizedBox(height: JoynTokens.md),
                                  const Text(
                                    'Défilement libre. Les étapes sont également accessibles par leurs boutons.',
                                  ),
                                ],
                              ),
                              trailing: AnimatedSwitcher(
                                duration: JoynTokens.menuDuration,
                                child: JourneyPreview(
                                  key: ValueKey(stage),
                                  stage: stage,
                                  compact: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
