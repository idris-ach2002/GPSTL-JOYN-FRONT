import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Logos officiels des services tiers (fichiers SVG dans `assets/icons/`).
///
/// Utilisés tels quels, sans modifier les couleurs ni les proportions,
/// comme l'exigent les chartes Google et LinkedIn.
class BrandLogo extends StatelessWidget {
  const BrandLogo.google({super.key, this.size = 20})
    : _asset = 'assets/icons/google.svg',
      _label = 'Google';

  const BrandLogo.linkedIn({super.key, this.size = 20})
    : _asset = 'assets/icons/linkedin.svg',
      _label = 'LinkedIn';

  final double size;
  final String _asset;
  final String _label;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _asset,
      width: size,
      height: size,
      semanticsLabel: 'Logo $_label',
    );
  }
}
