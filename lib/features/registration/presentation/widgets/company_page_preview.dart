import 'package:flutter/material.dart';

import '../../../../design_system/components/joyn_pill.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import 'registration_preview_shell.dart';

/// Aperçu en direct de la page entreprise (écran 02c).
class CompanyPagePreview extends StatelessWidget {
  const CompanyPagePreview({
    required this.companyInitial,
    required this.companyName,
    required this.companyMeta,
    required this.verified,
    required this.recruiterInitials,
    required this.recruiterName,
    required this.recruiterRole,
    super.key,
  });

  final String companyInitial;
  final String companyName;
  final String companyMeta;
  final bool verified;
  final String recruiterInitials;
  final String recruiterName;
  final String recruiterRole;

  @override
  Widget build(BuildContext context) {
    return RegistrationPreviewShell(
      title: 'Votre page entreprise',
      subtitle:
          'Ce que les candidats découvriront, mis à jour pendant que vous remplissez le formulaire.',
      card: PreviewCard(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 62,
                height: 62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x260E1F2A),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  companyInitial,
                  style: const TextStyle(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: verified
                    ? const JoynPill(
                        label: 'Entreprise vérifiée',
                        icon: Icons.verified_outlined,
                        background: AppColors.successTint,
                        foreground: AppColors.successDeep,
                        fontSize: 12,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      )
                    : const JoynPill(
                        label: 'En attente du SIRET',
                        background: AppColors.background,
                        foreground: AppColors.slate,
                        fontSize: 12,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Semantics(
            liveRegion: true,
            child: Text(
              companyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppFonts.display,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.48,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            companyMeta,
            style: const TextStyle(fontSize: 13, color: AppColors.slate),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.orangeLight,
                  child: Text(
                    recruiterInitials,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recruiterName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '$recruiterRole · recrute sur Joyn',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const PreviewNextSteps(
            steps: [
              PreviewStep(
                icon: Icons.checklist_rounded,
                title: 'Décrivez vos besoins',
                subtitle: 'Métiers, nombre d’alternants, rentrée',
              ),
              PreviewStep(
                icon: Icons.edit_note_rounded,
                title: 'Publiez votre offre',
                subtitle: 'Missions, rythme et compétences',
              ),
              PreviewStep(
                icon: Icons.people_alt_outlined,
                title: 'Recevez des profils compatibles',
                subtitle: 'Triés par score, souvent cooptés',
                accent: true,
              ),
            ],
          ),
        ],
      ),
      footer: const PreviewFooter(
        title: 'Ils cherchent leur alternance sur Joyn',
        roundAvatars: true,
        badges: [
          PreviewBadge('YK', 'Yasmine K.', AppColors.cyanBlue, AppColors.textPrimary),
          PreviewBadge('HL', 'Hugo L.', AppColors.orangeLight, AppColors.textPrimary),
          PreviewBadge('NB', 'Nora B.', AppColors.skyMist, AppColors.textPrimary),
        ],
        icon: Icons.verified_user_outlined,
        note:
            'Chaque entreprise est vérifiée par notre équipe avant la publication de sa première offre.',
      ),
    );
  }
}
