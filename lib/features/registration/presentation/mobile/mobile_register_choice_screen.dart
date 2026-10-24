import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/material/joyn_chip_group.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import 'mobile_register_header.dart';

/// Inscription mobile, étape 1 : choix du profil.
class MobileRegisterChoiceScreen extends StatelessWidget {
  const MobileRegisterChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return JoynMaterialScope(
      child: MobileAppSurface(
        systemUiOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: const Color(0xFFF7F8F2),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MobileRegisterHeader(
                onBack: () => context.go(AppRoutes.login),
                title: 'Quel est ton profil ?',
                subtitle: 'On adapte JOYN à ton objectif dès le départ.',
              ),
              const SizedBox(height: 26),
              _ProfileChoiceCard(
                key: const ValueKey('mobile-register-student'),
                icon: Icons.school_rounded,
                tint: AppColors.skyTint,
                badge: 'Étudiant·e',
                title: 'Je cherche une alternance',
                description: 'Crée ton profil, découvre tes meilleurs matchs et échange avec les entreprises.',
                onTap: () => context.go(AppRoutes.candidateRegister),
              ),
              const SizedBox(height: 14),
              _ProfileChoiceCard(
                key: const ValueKey('mobile-register-company'),
                icon: Icons.business_center_rounded,
                tint: AppColors.orangeTint,
                badge: 'Entreprise',
                title: 'Je recrute',
                description: 'Publie tes besoins et rencontre les profils les plus compatibles.',
                onTap: () => context.go(AppRoutes.recruiterRegister),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Déjà inscrit·e ? Se connecter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileChoiceCard extends StatelessWidget {
  const _ProfileChoiceCard({
    required this.icon,
    required this.tint,
    required this.badge,
    required this.title,
    required this.description,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final Color tint;
  final String badge;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: tint,
                    child: Icon(icon, color: AppColors.navy),
                  ),
                  const Spacer(),
                  JoynInfoChip(
                    label: badge,
                    background: tint,
                    foreground: AppColors.navy,
                    small: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(title, style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerRight,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.navy,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.white,
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
