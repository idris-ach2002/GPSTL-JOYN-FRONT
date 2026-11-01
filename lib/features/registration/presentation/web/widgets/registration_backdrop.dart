import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/design_system/tokens/app_gradients.dart';
import 'package:joyn_front/features/registration/presentation/web/widgets/dot_grid.dart';

/// Fond de l'écran de choix du profil : bleu nuit en haut, clair en bas,
/// avec deux halos et une trame de points qui s'efface.
class RegistrationBackdrop extends StatelessWidget {
  const RegistrationBackdrop({required this.child, super.key});

  final Widget child;

  static const double _gradientHeight = 620;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _gradientHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.registrationBackdrop,
              ),
            ),
          ),
          const Positioned(
            top: -260,
            right: -220,
            width: 760,
            height: 760,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradients.heroBlueGlow),
              ),
            ),
          ),
          const Positioned(
            top: -200,
            left: -160,
            width: 560,
            height: 560,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.heroOrangeGlow,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 520,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white, Colors.transparent],
                stops: [0, 0.55, 1],
              ).createShader(rect),
              child: const DotGrid(),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
