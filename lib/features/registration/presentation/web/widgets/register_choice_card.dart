import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/material/joyn_chip_group.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/design_system/tokens/app_durations.dart';

/// Carte sélectionnable ([Card]) de l'étape 1 : « Étudiant·e » ou
/// « Entreprise ».
///
/// Les deux cartes forment un groupe à choix unique (sémantique de bouton
/// radio pour les lecteurs d'écran).
class RegisterChoiceCard extends StatefulWidget {
  const RegisterChoiceCard({
    required this.selected,
    required this.onSelected,
    required this.illustration,
    required this.tagLabel,
    required this.tagIcon,
    required this.tint,
    required this.tintForeground,
    required this.title,
    required this.description,
    required this.benefits,
    this.illustrationHeight = 214,
    this.showBenefits = true,
    super.key,
  });

  final bool selected;
  final VoidCallback onSelected;
  final Widget illustration;
  final String tagLabel;
  final IconData tagIcon;

  /// Couleur douce de la puce et des coches (bleu ou orange).
  final Color tint;
  final Color tintForeground;

  final String title;
  final String description;
  final List<String> benefits;

  /// Hauteur de l'illustration du haut (réduite sur les fenêtres basses).
  final double illustrationHeight;

  /// `false` pour masquer la liste des avantages (fenêtres basses).
  final bool showBenefits;

  @override
  State<RegisterChoiceCard> createState() => _RegisterChoiceCardState();
}

class _RegisterChoiceCardState extends State<RegisterChoiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: widget.title,
      child: AnimatedSlide(
        duration: reduceMotion ? Duration.zero : AppDurations.normal,
        offset: Offset(0, _hovered && !reduceMotion ? -0.01 : 0),
        child: Card(
          elevation: selected ? 10 : 2,
          shadowColor: const Color(0x400E1F2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color: selected ? AppColors.navy : AppColors.surface,
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: widget.onSelected,
            onHover: (value) => setState(() => _hovered = value),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: widget.illustrationHeight,
                      child: _ScaledIllustration(child: widget.illustration),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        28,
                        widget.showBenefits ? 22 : 18,
                        28,
                        widget.showBenefits ? 18 : 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          JoynInfoChip(
                            label: widget.tagLabel,
                            icon: widget.tagIcon,
                            background: widget.tint,
                            foreground: widget.tintForeground,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.title,
                            style: textTheme.headlineSmall?.copyWith(
                              fontSize: 26,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.description,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.slateDark,
                            ),
                          ),
                          if (widget.showBenefits) const SizedBox(height: 6),
                          if (widget.showBenefits)
                            for (final benefit in widget.benefits)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                minLeadingWidth: 22,
                                visualDensity: VisualDensity.compact,
                                leading: CircleAvatar(
                                  radius: 11,
                                  backgroundColor: widget.tint,
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 13,
                                    color: widget.tintForeground,
                                  ),
                                ),
                                title: Text(
                                  benefit,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.slateDark,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 32,
                    color: selected ? AppColors.navy : AppColors.lineDashed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Affiche l'illustration (dessinée pour 214 px de haut) à la hauteur
/// disponible, en la réduisant proportionnellement au lieu de la couper.
class _ScaledIllustration extends StatelessWidget {
  const _ScaledIllustration({required this.child});

  final Widget child;

  static const double _designHeight = 214;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxHeight / _designHeight;
        if (scale <= 0 || !constraints.hasBoundedWidth) return child;
        return FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: constraints.maxWidth / scale,
            height: _designHeight,
            child: child,
          ),
        );
      },
    );
  }
}
