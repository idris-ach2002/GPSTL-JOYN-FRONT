// Carrousel horizontal à hauteur naturelle, utilisable au geste et au clavier.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/joyn_tokens.dart';

/// Autorise le glisser à la souris comme au doigt.
class CarouselScrollBehavior extends MaterialScrollBehavior {
  /// Étend les gestes natifs au pointeur de souris.
  const CarouselScrollBehavior();

  /// Ne transforme pas la molette verticale avec une touche modificatrice.
  @override
  Set<LogicalKeyboardKey> get pointerAxisModifiers => const {};
  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}

/// Affiche les cartes à leur hauteur complète ; seul le contenu horizontal défile.
///
/// Les enfants doivent pouvoir calculer leur hauteur intrinsèque. La rangée
/// prend la hauteur du plus grand enfant et ne crée pas de scroll vertical interne.
class NaturalCarousel extends StatefulWidget {
  /// Identifie la vue et fixe la largeur relative de ses cartes.
  const NaturalCarousel({
    super.key,
    required this.items,
    required this.id,
    this.viewportFraction = 1,
    this.onChanged,
  });

  /// Cartes construites dans leur ordre de lecture.
  final List<Widget> items;

  /// Préfixe stable des clés du défilement, du focus et du compteur.
  final String id;

  /// Fraction de la largeur disponible occupée par une carte.
  final double viewportFraction;

  /// Notifie le propriétaire lorsque la carte la plus proche change.
  final ValueChanged<int>? onChanged;
  @override
  State<NaturalCarousel> createState() => _NaturalCarouselState();
}

/// Conserve le défilement, le focus et la sélection de cette instance.
class _NaturalCarouselState extends State<NaturalCarousel> {
  /// Position horizontale ; libérée avec le composant.
  final controller = ScrollController();

  /// Reçoit les flèches du clavier dans la zone du carrousel.
  final focus = FocusNode();

  /// Carte la plus proche de l’alignement central.
  int active = 0;

  /// Largeur d’une carte, recalculée selon les contraintes.
  double step = 0;

  /// Date du dernier geste de molette accepté.
  DateTime? lastWheel;

  @override
  void initState() {
    super.initState();
    controller.addListener(updateIndex);
  }

  /// Déduit l’indice courant de la position, sans dépasser le catalogue.
  void updateIndex() {
    if (step <= 0 || widget.items.isEmpty) {
      return;
    }
    final index = (controller.offset / step)
        .round()
        .clamp(0, widget.items.length - 1)
        .toInt();
    if (index != active) {
      setState(() => active = index);
      widget.onChanged?.call(index);
    }
  }

  /// Les touches et la molette restent bornées à la première/dernière carte.
  void select(int index) {
    if (!controller.hasClients || index < 0 || index >= widget.items.length) {
      return;
    }
    final offset = (index * step)
        .clamp(0.0, controller.position.maxScrollExtent)
        .toDouble();
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.jumpTo(offset);
    } else {
      controller.animateTo(
        offset,
        duration: JoynTokens.menuDuration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Seule une composante réellement horizontale est consommée, sans modificateur.
  void handleSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent ||
        event.scrollDelta.dx.abs() <= event.scrollDelta.dy.abs() ||
        event.scrollDelta.dx.abs() < JoynTokens.wheelThreshold) {
      return;
    }
    final index = active + (event.scrollDelta.dx > 0 ? 1 : -1);
    if (index < 0 || index >= widget.items.length) {
      return;
    }
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      final now = DateTime.now();
      if (lastWheel == null ||
          now.difference(lastWheel!) >= JoynTokens.wheelInterval) {
        lastWheel = now;
        focus.requestFocus();
        select(index);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
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
    child: Focus(
      key: ValueKey('${widget.id}-focus'),
      focusNode: focus,
      child: MouseRegion(
        onEnter: (_) => focus.requestFocus(),
        child: Listener(
          onPointerDown: (_) => focus.requestFocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  step = constraints.maxWidth * widget.viewportFraction;
                  final edge = (constraints.maxWidth - step) / 2;
                  return ScrollConfiguration(
                    behavior: const CarouselScrollBehavior(),
                    child: SingleChildScrollView(
                      key: ValueKey('${widget.id}-pages'),
                      controller: controller,
                      scrollDirection: Axis.horizontal,
                      physics: _CarouselSnapPhysics(step: step),
                      padding: EdgeInsets.symmetric(horizontal: edge),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final item in widget.items)
                              SizedBox(
                                width: step,
                                child: Listener(
                                  behavior: HitTestBehavior.translucent,
                                  onPointerSignal: handleSignal,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: widget.viewportFraction < 1
                                          ? JoynTokens.xs
                                          : 0,
                                    ),
                                    child: item,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: JoynTokens.md),
              Semantics(
                liveRegion: true,
                label: 'Élément ${active + 1} sur ${widget.items.length}',
                child: Text(
                  '${active + 1} / ${widget.items.length}',
                  key: ValueKey('${widget.id}-position'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Termine un glisser sur une carte entière, y compris avec une largeur fractionnée.
class _CarouselSnapPhysics extends ScrollPhysics {
  /// Fixe la distance entre deux positions d’arrêt.
  const _CarouselSnapPhysics({required this.step, super.parent});

  /// Largeur d’une carte en pixels logiques.
  final double step;
  @override
  _CarouselSnapPhysics applyTo(ScrollPhysics? ancestor) =>
      _CarouselSnapPhysics(step: step, parent: buildParent(ancestor));
  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (step <= 0 || position.outOfRange) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = toleranceFor(position);
    var page = position.pixels / step;
    if (velocity > tolerance.velocity) {
      page += .5;
    } else if (velocity < -tolerance.velocity) {
      page -= .5;
    }
    final target = (page.round() * step)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if ((target - position.pixels).abs() < tolerance.distance) {
      return null;
    }
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }
}
