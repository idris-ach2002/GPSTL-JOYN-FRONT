import 'package:flutter/material.dart';

import 'package:joyn_front/design_system/components/joyn_pill.dart';
import 'package:joyn_front/design_system/components/joyn_score_ring.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/design_system/tokens/app_fonts.dart';
import 'package:joyn_front/features/registration/presentation/widgets/registration_preview_shell.dart';

/// Aperçu en direct du profil étudiant (écran 02b).
class ProfileLivePreview extends StatelessWidget {
  const ProfileLivePreview({
    required this.initials,
    required this.displayName,
    required this.verifiedStudent,
    super.key,
  });

  final String initials;
  final String displayName;
  final bool verifiedStudent;

  @override
  Widget build(BuildContext context) {
    return RegistrationPreviewShell(
      title: 'Ton profil prend forme',
      subtitle: 'Ce que les entreprises verront de toi, mis à jour pendant que tu remplis le formulaire.',
      card: PreviewCard(
        floating: const PreviewFloatingChip(
          leading: JoynScoreRing(score: 92),
          title: 'Nébula Pay',
          subtitle: "Exemple d'offre compatible",
        ),
        children: [
          Semantics(
            liveRegion: true,
            label: 'Aperçu : $displayName',
            excludeSemantics: true,
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.cyanBlue,
                    shape: BoxShape.circle,
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
                    initials,
                    style: const TextStyle(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppFonts.display,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.44,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        "Étudiant·e · en recherche d'alternance",
                        style: TextStyle(fontSize: 13, color: AppColors.slate),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (verifiedStudent)
                const JoynPill(
                  label: 'Étudiant·e vérifié·e',
                  icon: Icons.verified_user_outlined,
                  background: AppColors.successTint,
                  foreground: AppColors.successDeep,
                  fontSize: 12,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
              const JoynPill(
                label: 'CV à importer',
                icon: Icons.description_outlined,
                background: AppColors.background,
                foreground: AppColors.slate,
                fontSize: 12,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const PreviewNextSteps(
            steps: [
              PreviewStep(
                icon: Icons.upload_file_outlined,
                title: 'Importe ton CV',
                subtitle: 'Formation et compétences pré-remplies',
              ),
              PreviewStep(
                icon: Icons.tune_rounded,
                title: 'Règle tes préférences',
                subtitle: 'Rythme, trajet et métiers',
              ),
              PreviewStep(
                icon: Icons.favorite_rounded,
                title: 'Swipe tes premières offres',
                subtitle: 'Chacune avec son score de compatibilité',
                accent: true,
              ),
            ],
          ),
        ],
      ),
      footer: const PreviewFooter(
        title: 'Elles recrutent en alternance sur Joyn',
        badges: [
          PreviewBadge(
            'N',
            'Nébula Pay',
            AppColors.textPrimary,
            AppColors.white,
          ),
          PreviewBadge(
            'L',
            'Lumen Santé',
            AppColors.cyanBlue,
            AppColors.textPrimary,
          ),
          PreviewBadge(
            'K',
            'Kôr Mobility',
            AppColors.navyLight,
            AppColors.white,
          ),
        ],
        icon: Icons.lock_outline_rounded,
        note: "Ton CV n'est envoyé qu'aux entreprises auxquelles tu dis « Intéressé ».",
      ),
    );
  }
}
