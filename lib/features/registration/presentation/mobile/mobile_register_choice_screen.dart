import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/joyn_logo.dart';

/// Entrée d'inscription dédiée aux applications mobiles.
///
/// Elle réutilise ensuite les parcours étudiant / entreprise existants, mais
/// évite d'afficher les grandes cartes de la mise en page web sur téléphone.
class MobileRegisterChoiceScreen extends StatelessWidget {
  const MobileRegisterChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton.filledTonal(
                      key: const ValueKey('mobile-register-back'),
                      tooltip: 'Retour à la connexion',
                      onPressed: () => context.go(AppRoutes.login),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    const Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: JoynLogo(size: 34),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 34),
                const Text(
                  'Bienvenue sur joyn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 31,
                    height: 1.04,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choisis ton espace. Tu pourras compléter ton profil juste après.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                _ProfileChoiceCard(
                  key: const ValueKey('mobile-choice-student'),
                  accent: AppColors.sky,
                  icon: Icons.school_rounded,
                  eyebrow: 'CANDIDAT',
                  title: 'Je cherche une alternance',
                  description: 'Crée ton profil, découvre tes meilleurs matchs et échange au bon moment.',
                  chips: const ['Profil CV', 'Score clair', 'Match réciproque'],
                  onTap: () => context.go(AppRoutes.candidateRegister),
                ),
                const SizedBox(height: 14),
                _ProfileChoiceCard(
                  key: const ValueKey('mobile-choice-company'),
                  accent: AppColors.coral,
                  icon: Icons.apartment_rounded,
                  eyebrow: 'ENTREPRISE',
                  title: 'Je recrute',
                  description: 'Publie une offre et identifie les profils vraiment compatibles avec ton besoin.',
                  chips: const ['Offres', 'Talents', 'Pipeline'],
                  onTap: () => context.go(AppRoutes.recruiterRegister),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Déjà inscrit ?',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      key: const ValueKey('mobile-register-login'),
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileChoiceCard extends StatelessWidget {
  const _ProfileChoiceCard({
    super.key,
    required this.accent,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.chips,
    required this.onTap,
  });

  final Color accent;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final List<String> chips;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE1E9EE)),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: .06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(icon, color: accent, size: 27),
                  ),
                  const Spacer(),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                eyebrow,
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 23,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.7,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final chip in chips)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .09),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        chip,
                        style: TextStyle(
                          color: accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
