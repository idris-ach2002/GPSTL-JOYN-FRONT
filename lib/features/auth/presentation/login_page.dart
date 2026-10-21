import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../app/routing/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/joyn_logo.dart';
import 'mobile/mobile_login_screen.dart';
import 'widgets/auth_showcase_panel.dart';
import 'widgets/login_form.dart';

/// Écran de connexion (route `/login`).
///
/// - Grand écran (web) : formulaire à gauche, panneau illustré à droite.
/// - Petit écran (mobile) : formulaire seul, en pleine largeur.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.mobile = false});

  final bool mobile;

  @override
  Widget build(BuildContext context) {
    if (mobile) return const MobileLoginScreen();

    final size = MediaQuery.sizeOf(context);
    final isWide =
        size.width >= AppBreakpoints.desktop &&
        size.height >= AppBreakpoints.minShowcaseHeight;

    return Scaffold(
      backgroundColor: isWide ? AppColors.background : AppColors.surface,
      body: SafeArea(
        child: isWide
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _FormSection(compact: false)),
                    SizedBox(width: AppSpacing.md),
                    Expanded(child: AuthShowcasePanel()),
                  ],
                ),
              )
            : const _FormSection(compact: true),
      ),
    );
  }
}

/// Colonne du formulaire : logo en haut, formulaire centré et défilable.
class _FormSection extends StatelessWidget {
  const _FormSection({required this.compact});

  /// Mise en page mobile : pas de carte, lien d'inscription sous le formulaire.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            0,
          ),
          child: Row(
            children: [
              const JoynLogo(),
              const Spacer(),
              if (!compact)
                const Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _SignUpLink(),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.formMaxWidth,
                ),
                child: Column(
                  children: [
                    const LoginForm(),
                    if (compact) ...[
                      const SizedBox(height: AppSpacing.lg),
                      const _SignUpLink(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if (compact) return content;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: content,
    );
  }
}

/// « Pas encore de compte ? Créer un compte ».
class _SignUpLink extends StatelessWidget {
  const _SignUpLink();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Pas encore de compte ?',
          style: AppTextStyles.caption.copyWith(fontSize: 14),
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.register),
          child: const Text('Créer un compte'),
        ),
      ],
    );
  }
}
