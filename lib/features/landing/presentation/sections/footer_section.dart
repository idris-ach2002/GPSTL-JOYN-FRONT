import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../information/domain/footer_links.dart';
import '../navigation/landing_section.dart';
import '../widgets/footer_curve.dart';
import '../widgets/joyn_mark.dart';

/// Footer clair de la maquette : marque puis Produit, Entreprises, Ressources,
/// Légal. Seule addition conservée : le fil orange lié au défilement.
class FooterSection extends StatelessWidget {
  const FooterSection({required this.onNavigate, required this.scrollController, super.key});
  final LandingNavigate onNavigate;
  final ScrollController scrollController;

  void _open(BuildContext context, String route) {
    if (route == '/tarifs') {
      onNavigate(LandingSection.pricing);
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) => ColoredBox(color: AppColors.background,
    child: ContentContainer(maxWidth: 1440,
      child: Padding(padding: const EdgeInsets.only(top: 10, bottom: 30),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FooterCurve(scrollController: scrollController),
          const SizedBox(height: 28),
          LayoutBuilder(builder: (context, constraints) {
            final count = constraints.maxWidth >= 1100 ? 5
              : constraints.maxWidth >= 780 ? 3 : constraints.maxWidth >= 520 ? 2 : 1;
            final width = (constraints.maxWidth - (count - 1) * 30) / count;
            return Wrap(spacing: 30, runSpacing: 38, children: [
              SizedBox(width: width, child: const _BrandBlock()),
              for (final group in footerLinks.entries)
                SizedBox(width: width, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(padding: const EdgeInsets.only(top: 8, bottom: 24),
                      child: Text(group.key, style: const TextStyle(fontSize: 20,
                        color: AppColors.navy, fontWeight: FontWeight.w700))),
                    for (final link in group.value.entries)
                      TextButton(
                        style: TextButton.styleFrom(alignment: Alignment.centerLeft,
                          padding: EdgeInsets.zero, foregroundColor: AppColors.blueGreyDark,
                          textStyle: const TextStyle(fontSize: 13)),
                        onPressed: () => _open(context, link.value), child: Text(link.key)),
                  ])),
            ]);
          }),
          const SizedBox(height: 56),
          Divider(color: AppColors.navy.withValues(alpha: .09)),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            const copyright = Text('© 2026 Joyn',
              style: TextStyle(color: AppColors.blueGreyDark, fontSize: 12));
            const signature = Text('Fait pour les alternants, par des alternants.',
              style: TextStyle(color: AppColors.blueGreyDark, fontSize: 12));
            if (constraints.maxWidth < 700) {
              return const Wrap(spacing: 24, runSpacing: 16, children: [copyright, signature]);
            }
            return const Row(children: [copyright, Spacer(), signature]);
          }),
        ])),
    ),
  );
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [JoynMark(size: 40), SizedBox(width: 14),
        Text('joyn', style: TextStyle(color: AppColors.navy,
          fontSize: 28, fontWeight: FontWeight.w800))]),
      SizedBox(height: 28),
      Text('Joyn a job with joy. Le matching réciproque entre étudiants et entreprises.',
        style: TextStyle(color: AppColors.blueGreyDark, fontSize: 13, height: 1.5)),
    ],
  );
}
