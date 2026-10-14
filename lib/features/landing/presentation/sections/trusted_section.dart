import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../widgets/landing_motion.dart';

class TrustedSection extends StatelessWidget {
  const TrustedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 34),
          child: LandingReveal(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 28,
              runSpacing: 14,
              children: const [
                Text(
                  'PENSÉ POUR LES MÉTIERS QUI BOUGENT',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.35,
                  ),
                ),
                _Sector(label: 'TECH'),
                _Sector(label: 'DESIGN'),
                _Sector(label: 'DATA'),
                _Sector(label: 'FINANCE'),
                _Sector(label: 'CONSEIL'),
                _Sector(label: 'PRODUIT'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Sector extends StatelessWidget {
  const _Sector({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.navy,
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}
