import 'package:flutter/material.dart';

/// JOYN reference wordmark; the compact mark uses the same brand asset.
class JoynLogo extends StatelessWidget {
  const JoynLogo({
    this.onDark = false,
    this.markSize = 34,
    this.showWordmark = true,
    super.key,
  });

  static const String markAsset = 'assets/images/joyn_logo.png';
  final bool onDark;
  final double markSize;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'JOYN',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: onDark ? Colors.transparent : const Color(0xFF001E3B),
          borderRadius: BorderRadius.circular(markSize * 0.22),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: markSize * 0.16,
          vertical: markSize * 0.08,
        ),
        child: Image.asset(
          markAsset,
          height: markSize,
          width: showWordmark ? markSize * 2 : markSize,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
