import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/tokens/app_colors.dart';

class MobileRegisterChoiceScreen extends StatelessWidget {
  const MobileRegisterChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileAppSurface(
      systemUiOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: const Color(0xFFF7F8F2),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () => context.go(AppRoutes.login),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const Spacer(),
                const MobileBrandMark(compact: true),
              ],
            ),
            const SizedBox(height: 34),
            const Text(
              'Quel est ton profil ?',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 32,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'On adapte JOYN à ton objectif dès le départ.',
              style: TextStyle(
                color: AppColors.slate,
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            _ProfileChoiceCard(
              key: const ValueKey('mobile-register-student'),
              icon: Icons.school_rounded,
              accent: const Color(0xFFE7F3FF),
              title: 'Je cherche une alternance',
              description: 'Crée ton profil, découvre tes meilleurs matchs et échange avec les entreprises.',
              badge: 'Candidat',
              onTap: () => context.go(AppRoutes.candidateRegister),
            ),
            const SizedBox(height: 16),
            _ProfileChoiceCard(
              key: const ValueKey('mobile-register-company'),
              icon: Icons.business_center_rounded,
              accent: const Color(0xFFFFE9E1),
              title: 'Je recrute',
              description: 'Publie tes besoins et rencontre les profils les plus compatibles.',
              badge: 'Entreprise',
              onTap: () => context.go(AppRoutes.recruiterRegister),
            ),
            const SizedBox(height: 28),
            Center(
              child: TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text(
                  'Déjà inscrit ? Se connecter',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileChoiceCard extends StatelessWidget {
  const _ProfileChoiceCard({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String description;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.navy),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 21,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.slate,
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerRight,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.navy,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
