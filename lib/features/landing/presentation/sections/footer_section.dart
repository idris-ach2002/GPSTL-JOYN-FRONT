import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../widgets/joyn_mark.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF2F6F9),
      child: ContentContainer(
        maxWidth: 1240,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 54, 0, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: Color(0xFFDCE5EB)),
              const SizedBox(height: 34),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 820;
                  final brand = const _BrandBlock();
                  final columns = const Wrap(
                    spacing: 58,
                    runSpacing: 32,
                    children: [
                      _FooterColumn(
                        title: 'Produit',
                        links: ['Comment ça marche', 'JOYN+', 'Remplace-moi'],
                      ),
                      _FooterColumn(
                        title: 'Entreprises',
                        links: [
                          'Publier une offre',
                          'Espace recruteur',
                          'Tarifs',
                        ],
                      ),
                      _FooterColumn(
                        title: 'Ressources',
                        links: [
                          "Guide de l'alternance",
                          'Questions fréquentes',
                          'Contact',
                        ],
                      ),
                      _FooterColumn(
                        title: 'Légal',
                        links: [
                          'Confidentialité',
                          "Conditions d'utilisation",
                          'Cookies',
                        ],
                      ),
                    ],
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [brand, SizedBox(height: 38), columns],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 210, child: brand),
                      SizedBox(width: 58),
                      Expanded(child: columns),
                    ],
                  );
                },
              ),
              const SizedBox(height: 42),
              const Divider(color: Color(0xFFDCE5EB)),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final mobile = constraints.maxWidth < 760;
                  final left = const Text(
                    '© 2026 JOYN',
                    style: TextStyle(color: Color(0xFF8192A2), fontSize: 11),
                  );
                  final right = const Text(
                    'Produit en développement · Démonstrations illustratives.',
                    style: TextStyle(color: Color(0xFF8192A2), fontSize: 11),
                  );
                  if (mobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [left, SizedBox(height: 8), right],
                    );
                  }
                  return Row(children: [left, Spacer(), right]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            JoynMark(size: 34),
            SizedBox(width: AppSpacing.sm),
            Text(
              'joyn',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Joyn a job with joy. Le matching réciproque entre étudiants et entreprises.',
          style: TextStyle(
            color: Color(0xFF8192A2),
            fontSize: 11,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.links});
  final String title;
  final List<String> links;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          for (final link in links)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                link,
                style: const TextStyle(color: Color(0xFF8192A2), fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
