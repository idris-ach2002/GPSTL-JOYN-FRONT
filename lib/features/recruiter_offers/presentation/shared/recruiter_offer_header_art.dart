import 'package:flutter/material.dart';

/// Fond statique premium du header "Mes offres".
///
/// Le visuel est un asset illustré dédié, mais il est fusionné au composant
/// avec plusieurs overlays Flutter pour conserver l'impression d'un vrai
/// design natif plutôt que d'une image simplement posée en arrière-plan.
class RecruiterOfferHeaderArt extends StatelessWidget {
  const RecruiterOfferHeaderArt({super.key, this.animate = false});

  /// Conservé pour compatibilité avec les anciens appels.
  final bool animate;

  static const _desktopAsset =
      'assets/images/recruiter_offers/joyn_header_desktop.png';
  static const _mobileAsset =
      'assets/images/recruiter_offers/joyn_header_mobile.png';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        return RepaintBoundary(
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Color(0xFF061F3A)),
                Image.asset(
                  isMobile ? _mobileAsset : _desktopAsset,
                  fit: BoxFit.cover,
                  alignment: isMobile ? Alignment.center : Alignment.center,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                ),

                // Wash bleu uniforme : fond l'image dans la palette JOYN.
                const DecoratedBox(
                  decoration: BoxDecoration(color: Color(0x12082749)),
                ),

                // Zone gauche protégée pour le titre, sans cacher les volumes.
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: isMobile
                          ? const [
                              Color(0xC9061F3A),
                              Color(0x90061F3A),
                              Color(0x28061F3A),
                              Color(0x00061F3A),
                            ]
                          : const [
                              Color(0xE0061F3A),
                              Color(0xA8061F3A),
                              Color(0x3D061F3A),
                              Color(0x00061F3A),
                            ],
                      stops: isMobile
                          ? const [0, .28, .64, 1]
                          : const [0, .18, .43, .72],
                    ),
                  ),
                ),

                // Fondu inférieur pour raccorder naturellement le header au bloc
                // de recherche blanc qui vient juste en dessous.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00061F3A),
                        Color(0x00061F3A),
                        Color(0x1C061F3A),
                      ],
                      stops: [0, .72, 1],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
