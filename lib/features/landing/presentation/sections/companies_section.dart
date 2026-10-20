import 'package:flutter/material.dart';

import '../../../../design_system/layout/content_container.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../widgets/section_header.dart';

/// Chapitre entreprise : composition texte / aperçu conforme à l'esprit Figma.
/// L'aperçu est explicitement illustratif et n'utilise aucune donnée personnelle.
class CompaniesSection extends StatelessWidget {
  const CompaniesSection({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.navy,
    child: ContentContainer(
      maxWidth: 1240,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 96),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  eyebrow: 'Pour les entreprises',
                  dark: true,
                  title: 'Le prochain talent.\nLa bonne rencontre.',
                  description:
                      'Présentez votre entreprise, publiez vos offres et '
                      'retrouvez les candidatures dans un espace dédié.',
                ),
                const SizedBox(height: 24),
                for (final text in [
                  'Des profils recommandés pour vos recrutements.',
                  'Vos offres, de la création à la clôture.',
                  'Des échanges liés à chaque candidature.',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            text,
                            style: const TextStyle(
                              color: AppColors.white,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/inscription'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.orange,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Créer un compte entreprise'),
                ),
              ],
            );
            const preview = _CompanyPreview();
            if (constraints.maxWidth < 900) {
              return Column(
                children: [copy, const SizedBox(height: 40), preview],
              );
            }
            return Row(
              children: [
                Expanded(flex: 6, child: copy),
                const SizedBox(width: 48),
                Expanded(flex: 5, child: preview),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _CompanyPreview extends StatelessWidget {
  const _CompanyPreview();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.cyanBlue,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Votre espace recrutement',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Aperçu illustratif',
          style: TextStyle(color: AppColors.white),
        ),
        const SizedBox(height: 24),
        for (final item in const [
          ('Profil recommandé', 'Compétences et parcours'),
          ('Candidature reçue', 'Informations à consulter'),
          ('Conversation', 'Échanges liés à votre offre'),
        ]) ...[
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: const CircleAvatar(
                backgroundColor: AppColors.blueGrey10,
                child: Icon(Icons.person_outline, color: AppColors.navy),
              ),
              title: Text(
                item.$1,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(item.$2),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    ),
  );
}
