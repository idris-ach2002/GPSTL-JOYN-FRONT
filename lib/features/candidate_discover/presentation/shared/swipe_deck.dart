import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../domain/recommended_offer.dart';

/// Pile de cartes que l'on fait glisser :
/// - à droite → [SwipeDecision.interested] ;
/// - à gauche → [SwipeDecision.skip] ;
/// - vers le haut → [SwipeDecision.save].
///
/// Les boutons d'action déclenchent la même animation via
/// `GlobalKey<SwipeDeckState>` et [SwipeDeckState.swipe].
class SwipeDeck extends StatefulWidget {
  const SwipeDeck({
    super.key,
    required this.offers,
    required this.cardBuilder,
    required this.onSwiped,
    this.visibleCount = 3,
    this.stackOffset = 14,
  });

  /// Offres restantes, la première étant au-dessus.
  final List<RecommendedOffer> offers;
  final Widget Function(BuildContext context, RecommendedOffer offer)
  cardBuilder;

  /// Appelé une fois la carte sortie de l'écran.
  final ValueChanged<SwipeDecision> onSwiped;

  /// Nombre de cartes dessinées (celle du dessus + celles qui dépassent).
  final int visibleCount;

  /// Décalage vertical des cartes du dessous, qui dépassent au-dessus.
  final double stackOffset;

  @override
  State<SwipeDeck> createState() => SwipeDeckState();
}

class SwipeDeckState extends State<SwipeDeck>
    with SingleTickerProviderStateMixin {
  /// Part de la largeur à dépasser pour valider un glissement horizontal.
  static const double _horizontalThreshold = 0.28;

  /// Part de la hauteur à dépasser pour valider un glissement vers le haut.
  static const double _verticalThreshold = 0.22;

  /// Vitesse (px/s) au-delà de laquelle un lancer rapide suffit.
  static const double _flingVelocity = 900;

  late final AnimationController _animation = AnimationController(vsync: this)
    ..addListener(_onTick);

  Animation<Offset>? _tween;
  Offset _drag = Offset.zero;
  Size _size = Size.zero;
  bool _busy = false;

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  void _onTick() {
    final tween = _tween;
    if (tween != null) setState(() => _drag = tween.value);
  }

  /// Fait sortir la carte du dessus, comme si le candidat l'avait glissée.
  Future<void> swipe(SwipeDecision decision) async {
    if (_busy || widget.offers.isEmpty) return;
    await _flyOut(decision);
  }

  Future<void> _animateTo(Offset target, Duration duration, Curve curve) {
    _tween = Tween<Offset>(
      begin: _drag,
      end: target,
    ).animate(CurvedAnimation(parent: _animation, curve: curve));
    _animation.duration = _reduceMotion ? Duration.zero : duration;
    return _animation.forward(from: 0).orCancel.catchError((_) {});
  }

  Future<void> _flyOut(SwipeDecision decision) async {
    _busy = true;
    final width = math.max(_size.width, 320.0);
    final height = math.max(_size.height, 320.0);
    final target = switch (decision) {
      SwipeDecision.interested => Offset(width * 1.6, _drag.dy + 40),
      SwipeDecision.skip => Offset(-width * 1.6, _drag.dy + 40),
      SwipeDecision.save => Offset(_drag.dx, -height * 1.6),
    };
    await _animateTo(
      target,
      const Duration(milliseconds: 280),
      Curves.easeInCubic,
    );
    if (!mounted) return;
    widget.onSwiped(decision);
    setState(() {
      _tween = null;
      _drag = Offset.zero;
      _busy = false;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_busy) return;
    setState(() => _drag += details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_busy) return;
    final velocity = details.velocity.pixelsPerSecond;
    final decision = _decisionFor(_drag, velocity);
    if (decision != null) {
      _flyOut(decision);
    } else {
      _animateTo(
        Offset.zero,
        const Duration(milliseconds: 320),
        Curves.easeOutBack,
      );
    }
  }

  SwipeDecision? _decisionFor(Offset drag, Offset velocity) {
    final width = _size.width == 0 ? 1 : _size.width;
    final height = _size.height == 0 ? 1 : _size.height;
    final vertical = drag.dy.abs() > drag.dx.abs();
    if (vertical) {
      if (drag.dy < -height * _verticalThreshold ||
          velocity.dy < -_flingVelocity) {
        return SwipeDecision.save;
      }
      return null;
    }
    if (drag.dx > width * _horizontalThreshold ||
        velocity.dx > _flingVelocity) {
      return SwipeDecision.interested;
    }
    if (drag.dx < -width * _horizontalThreshold ||
        velocity.dx < -_flingVelocity) {
      return SwipeDecision.skip;
    }
    return null;
  }

  /// Geste en cours et sa progression (0 → 1), pour le tampon visuel.
  (SwipeDecision?, double) _hint() {
    if (_size.isEmpty || _drag == Offset.zero) return (null, 0);
    if (_drag.dy.abs() > _drag.dx.abs()) {
      if (_drag.dy >= 0) return (null, 0);
      final progress = -_drag.dy / (_size.height * _verticalThreshold);
      return (SwipeDecision.save, progress.clamp(0, 1));
    }
    final progress = _drag.dx.abs() / (_size.width * _horizontalThreshold);
    return (
      _drag.dx > 0 ? SwipeDecision.interested : SwipeDecision.skip,
      progress.clamp(0, 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        final visible = widget.offers.take(widget.visibleCount).toList();
        final (hint, progress) = _hint();

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Cartes du dessous : de la plus lointaine à la plus proche.
            for (var depth = visible.length - 1; depth >= 1; depth--)
              Positioned.fill(
                key: ValueKey('deck-back-${visible[depth].id}'),
                child: IgnorePointer(
                  child: _BackCard(
                    depth: depth,
                    // La carte suivante avance pendant le glissement.
                    lift: depth == 1 ? _liftProgress() : 0,
                    offset: widget.stackOffset,
                    child: widget.cardBuilder(context, visible[depth]),
                  ),
                ),
              ),
            if (visible.isNotEmpty)
              Positioned.fill(
                key: ValueKey('deck-top-${visible.first.id}'),
                child: _TopCard(
                  drag: _drag,
                  width: _size.width,
                  hint: hint,
                  progress: progress,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  onAction: swipe,
                  child: widget.cardBuilder(context, visible.first),
                ),
              ),
          ],
        );
      },
    );
  }

  double _liftProgress() {
    if (_size.isEmpty) return 0;
    final distance = _drag.distance / (_size.width * _horizontalThreshold);
    return distance.clamp(0, 1).toDouble();
  }
}

class _BackCard extends StatelessWidget {
  const _BackCard({
    required this.depth,
    required this.lift,
    required this.offset,
    required this.child,
  });

  final int depth;
  final double lift;
  final double offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final level = depth - lift;
    return Transform.translate(
      offset: Offset(0, -offset * level),
      child: Transform.scale(
        scale: 1 - 0.05 * level,
        alignment: Alignment.topCenter,
        child: Opacity(
          opacity: (1 - 0.25 * level).clamp(0, 1),
          // Seul le cadre de la carte compte : le contenu reste masqué pour ne
          // pas surcharger la pile.
          child: ExcludeSemantics(child: child),
        ),
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  const _TopCard({
    required this.drag,
    required this.width,
    required this.hint,
    required this.progress,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onAction,
    required this.child,
  });

  final Offset drag;
  final double width;
  final SwipeDecision? hint;
  final double progress;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;
  final ValueChanged<SwipeDecision> onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final angle = width == 0 ? 0.0 : (drag.dx / width) * 0.22;
    return Semantics(
      customSemanticsActions: {
        for (final decision in SwipeDecision.values)
          CustomSemanticsAction(label: decision.label): () =>
              onAction(decision),
      },
      child: GestureDetector(
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: Transform.translate(
          offset: drag,
          child: Transform.rotate(
            angle: angle,
            alignment: Alignment.bottomCenter,
            child: Stack(
              fit: StackFit.expand,
              children: [
                child,
                if (hint != null && progress > 0)
                  _SwipeStamp(decision: hint!, opacity: progress),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tampon « POSTULER / PASSER / SAUVEGARDER » affiché pendant le glissement.
class _SwipeStamp extends StatelessWidget {
  const _SwipeStamp({required this.decision, required this.opacity});

  final SwipeDecision decision;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final (color, alignment, angle) = switch (decision) {
      SwipeDecision.interested => (AppColors.success, Alignment.topLeft, -0.2),
      SwipeDecision.skip => (AppColors.error, Alignment.topRight, 0.2),
      SwipeDecision.save => (AppColors.cyanBlue, Alignment.bottomCenter, 0.0),
    };
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Transform.rotate(
              angle: angle,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.85),
                  border: Border.all(color: color, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Text(
                    decision.label.toUpperCase(),
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
