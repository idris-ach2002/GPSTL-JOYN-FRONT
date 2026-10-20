import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../navigation/landing_section.dart';
import '../widgets/footer_curve.dart';
import '../widgets/joyn_mark.dart';

/// Footer bleu nuit de la capture corrigée : marque, promesse, courbe, 4 colonnes.
/// Tous les liens pointent vers une ancre ou une route existante.
class FooterSection extends StatelessWidget {
  const FooterSection({required this.onNavigate, super.key});
  final LandingNavigate onNavigate;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.navy,
    child: ContentContainer(maxWidth: 1440,
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 72),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [JoynMark(size: 46), SizedBox(width: 16),
            Text('joyn', style: TextStyle(color: AppColors.white,
              fontSize: 36, fontWeight: FontWeight.w800))]),
          const SizedBox(height: 40),
          Text('Une offre à lire.\nUne candidature à suivre.',
            style: TextStyle(color: AppColors.white, height: 1.15,
              fontSize: MediaQuery.sizeOf(context).width < 600 ? 30 : 42,
              fontWeight: FontWeight.w800, letterSpacing: -1)),
          const SizedBox(height: 24),
          const Text('Les parcours, les formules et l’aide, au même endroit.',
            style: TextStyle(color: AppColors.blue, fontSize: 19, height: 1.5)),
          const SizedBox(height: 12),
          const FooterCurve(),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, constraints) {
            final count = constraints.maxWidth >= 1000 ? 4
              : constraints.maxWidth >= 600 ? 2 : 1;
            final width = (constraints.maxWidth - 24 * (count - 1)) / count;
            return Wrap(spacing: 24, runSpacing: 24, children: [
              SizedBox(width: width, child: _FooterColumn(title: 'Candidats',
                icon: Icons.person_outline, links: {
                  'Les avantages candidat': () => onNavigate(LandingSection.features),
                  'Créer mon profil': () => Navigator.pushNamed(context, '/inscription'),
                  'Mon espace': () => Navigator.pushNamed(context, '/connexion'),
                })),
              SizedBox(width: width, child: _FooterColumn(title: 'Entreprises',
                icon: Icons.apartment_rounded, links: {
                  'Les avantages entreprise': () => onNavigate(LandingSection.companies),
                  'Présenter mon entreprise': () => Navigator.pushNamed(context, '/inscription'),
                  'Espace recruteur': () => Navigator.pushNamed(context, '/connexion'),
                })),
              SizedBox(width: width, child: _FooterColumn(title: 'Formules',
                icon: Icons.view_column_outlined, links: {
                  'JOYN, JOYN+ et Boost': () => onNavigate(LandingSection.pricing),
                  'Membre et Membre premium': () => onNavigate(LandingSection.pricing),
                  'Connexion': () => Navigator.pushNamed(context, '/connexion'),
                })),
              SizedBox(width: width, child: _FooterColumn(title: 'Assistance',
                icon: Icons.headset_mic_outlined, links: {
                  'Questions fréquentes': () => onNavigate(LandingSection.assistance),
                  'Découvrir les fonctionnalités': () => onNavigate(LandingSection.features),
                })),
            ]);
          }),
          const SizedBox(height: 40),
          Divider(color: AppColors.white.withValues(alpha: .15)),
          const SizedBox(height: 16),
          Wrap(spacing: 32, runSpacing: 16, crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('JOYN · Emploi et recrutement',
                style: TextStyle(color: AppColors.white)),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.white),
                onPressed: () => onNavigate(LandingSection.hero),
                icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                label: const Text('RETOUR EN HAUT')),
            ]),
        ])),
    ),
  );
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.icon, required this.links});
  final String title;
  final IconData icon;
  final Map<String, VoidCallback> links;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [Icon(icon, color: AppColors.white), const SizedBox(width: 16),
        Text(title, style: const TextStyle(color: AppColors.white,
          fontWeight: FontWeight.w800))]),
      const SizedBox(height: 20),
      for (final link in links.entries)
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.white,
            alignment: Alignment.centerLeft, padding: EdgeInsets.zero),
          onPressed: link.value, child: Text(link.key)),
    ],
  );
}
