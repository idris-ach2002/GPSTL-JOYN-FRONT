import 'dart:async';

import 'package:flutter/material.dart';

/// Background premium partagé par les écrans recruteur.
///
/// La rotation est basée sur une horloge globale. Dashboard, Offres et les
/// écrans analytiques affichent donc la même image au même instant, même après
/// navigation. Le visuel change toutes les 5 secondes avec un fondu lent.
class RecruiterOfferHeaderArt extends StatefulWidget {
  const RecruiterOfferHeaderArt({super.key, this.animate = true});

  final bool animate;

  @override
  State<RecruiterOfferHeaderArt> createState() =>
      _RecruiterOfferHeaderArtState();
}

class _RecruiterOfferHeaderArtState extends State<RecruiterOfferHeaderArt> {
  static const _rotation = Duration(seconds: 5);
  static const _assets = [
    'assets/images/recruiter_dashboard/headers/header_01.png',
    'assets/images/recruiter_dashboard/headers/header_02.png',
    'assets/images/recruiter_dashboard/headers/header_03.png',
    'assets/images/recruiter_dashboard/headers/header_04.png',
  ];

  Timer? _timer;
  late int _index;

  int _globalIndex() =>
      (DateTime.now().millisecondsSinceEpoch ~/ _rotation.inMilliseconds) %
      _assets.length;

  void _syncIndex() {
    if (!mounted) return;
    final next = _globalIndex();
    if (next != _index) setState(() => _index = next);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _syncIndex(),
    );
  }

  @override
  void initState() {
    super.initState();
    _index = _globalIndex();
    if (widget.animate) _startTimer();
  }

  @override
  void didUpdateWidget(covariant RecruiterOfferHeaderArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate == widget.animate) return;
    if (widget.animate) {
      _startTimer();
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF061F3A)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1700),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            layoutBuilder: (currentChild, previousChildren) => Stack(
              fit: StackFit.expand,
              children: [...previousChildren, ?currentChild],
            ),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.025, end: 1).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            ),
            child: SizedBox.expand(
              key: ValueKey(_assets[_index]),
              child: Image.asset(
                _assets[_index],
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
              ),
            ),
          ),
          // Wash uniforme : une image claire ne donne plus l'impression
          // que le header s'arrête avant le bord droit.
          const ColoredBox(color: Color(0x26061F3A)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xEE061F3A),
                  Color(0xBE061F3A),
                  Color(0x76061F3A),
                  Color(0x52061F3A),
                ],
                stops: [0, .27, .66, 1],
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x08000000),
                  Color(0x00061F3A),
                  Color(0x34061F3A),
                ],
                stops: [0, .56, 1],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
