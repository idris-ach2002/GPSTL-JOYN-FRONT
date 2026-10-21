import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/components/joyn_pill.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/design_system/tokens/app_durations.dart';
import 'package:joyn_front/design_system/tokens/app_fonts.dart';

/// Carte sélectionnable de l'étape 1 : « Étudiant·e » ou « Entreprise ».
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
    super.key,
  });

  final bool selected;
  final VoidCallback onSelected;
  final Widget illustration;
  final String tagLabel;
  final IconData tagIcon;

  /// Couleur douce de la pastille et des coches (bleu ou orange).
  final Color tint;
  final Color tintForeground;

  final String title;
  final String description;
  final List<String> benefits;

  @override
  State<RegisterChoiceCard> createState() => _RegisterChoiceCardState();
}

class _RegisterChoiceCardState extends State<RegisterChoiceCard> {
  bool _hovered = false;

  static const _radius = 30.0;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: widget.title,
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : AppDurations.normal,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          _hovered && !reduceMotion ? -4 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: selected
              ? const [
                  BoxShadow(color: Color(0x4D489EC9), spreadRadius: 6),
                  BoxShadow(
                    color: Color(0x290E1F2A),
                    blurRadius: 54,
                    offset: Offset(0, 26),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x140E1F2A),
                    blurRadius: 34,
                    offset: Offset(0, 14),
                  ),
                ],
        ),
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
            side: BorderSide(
              color: selected ? AppColors.navy : AppColors.surface,
              width: 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onSelected,
            onHover: (value) => setState(() => _hovered = value),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 214, child: widget.illustration),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 26, 30, 30),
                      child: _CardBody(card: widget),
                    ),
                  ],
                ),
                Positioned(
                  top: 18,
                  right: 18,
                  child: _SelectionDot(selected: selected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.card});

  final RegisterChoiceCard card;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JoynPill(
          label: card.tagLabel,
          icon: card.tagIcon,
          background: card.tint,
          foreground: card.tintForeground,
        ),
        const SizedBox(height: 12),
        Text(
          card.title,
          style: const TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 30,
            height: 1.08,
            letterSpacing: -0.9,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          card.description,
          style: const TextStyle(
            fontSize: 15,
            height: 1.55,
            color: AppColors.slateDark,
          ),
        ),
        const SizedBox(height: 16),
        for (final benefit in card.benefits)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: card.tint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 13,
                    color: card.tintForeground,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    benefit,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.slateDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.normal,
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: selected ? AppColors.navy : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.navy : AppColors.lineDashed,
          width: 2,
        ),
      ),
      child: AnimatedOpacity(
        duration: AppDurations.fast,
        opacity: selected ? 1 : 0,
        child: const Icon(
          Icons.check_rounded,
          size: 16,
          color: AppColors.white,
        ),
      ),
    );
  }
}
