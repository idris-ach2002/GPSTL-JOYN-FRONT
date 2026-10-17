import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_fonts.dart';

/// Logo Joyn : le pictogramme officiel et le mot « joyn ».
class JoynLogo extends StatelessWidget {
  const JoynLogo({
    this.onDark = false,
    this.markSize = 34,
    this.showWordmark = true,
    super.key,
  });

  /// Chemin du pictogramme (déclaré dans `pubspec.yaml`).
  static const String markAsset = 'assets/images/joyn_logo.png';

  /// À activer quand le logo est posé sur un fond bleu nuit
  /// (le mot « joyn » passe alors en blanc).
  final bool onDark;
  final double markSize;

  /// `false` pour n'afficher que le pictogramme.
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final mark = Image.asset(
      markAsset,
      width: markSize,
      height: markSize,
      filterQuality: FilterQuality.medium,
      semanticLabel: showWordmark ? null : 'Joyn',
      excludeFromSemantics: showWordmark,
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: markSize * 0.3),
        Text(
          'joyn',
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
            fontSize: markSize * 0.74,
            height: 1,
            letterSpacing: -markSize * 0.033,
            color: onDark ? AppColors.textOnDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
