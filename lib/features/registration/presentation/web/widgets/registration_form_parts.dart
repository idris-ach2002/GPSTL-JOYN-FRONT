import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/components/joyn_logo.dart';
import 'package:joyn_front/design_system/components/joyn_pill.dart';
import 'package:joyn_front/design_system/components/joyn_text_link.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/design_system/tokens/app_fonts.dart';

/// En-tête des formulaires d'inscription : logo + lien de connexion.
class RegistrationFormHeader extends StatelessWidget {
  const RegistrationFormHeader({
    required this.compact,
    required this.loginPrompt,
    super.key,
  });

  final bool compact;

  /// « Déjà inscrit·e ? » ou « Déjà un compte ? ».
  final String loginPrompt;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Semantics(
          link: true,
          label: "Joyn, retour à l'accueil",
          excludeSemantics: true,
          child: InkWell(
            onTap: () =>
                context.go(kIsWeb ? AppRoutes.landing : AppRoutes.login),
            borderRadius: BorderRadius.circular(12),
            child: const Padding(padding: EdgeInsets.all(4), child: JoynLogo()),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!compact)
              Text(
                '$loginPrompt ',
                style: const TextStyle(fontSize: 14, color: AppColors.slate),
              ),
            JoynTextLink(
              label: 'Se connecter',
              onTap: () => context.go(AppRoutes.login),
            ),
          ],
        ),
      ],
    );
  }
}

/// « ← Changer de profil » à gauche, « Étape 2 sur 2 » à droite.
class RegistrationStepRow extends StatelessWidget {
  const RegistrationStepRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        JoynTextLink(
          label: 'Changer de profil',
          leadingIcon: Icons.arrow_back_rounded,
          onTap: () => context.go(AppRoutes.register),
        ),
        Semantics(
          label: 'Étape 2 sur 2',
          excludeSemantics: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Étape 2 sur 2',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate,
                ),
              ),
              const SizedBox(width: 10),
              for (var i = 0; i < 2; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Container(
                  width: 22,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Pastille, titre et phrase d'introduction d'un formulaire d'inscription.
class RegistrationIntro extends StatelessWidget {
  const RegistrationIntro({
    required this.pill,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final JoynPill pill;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final titleSize = (MediaQuery.sizeOf(context).width * 0.03)
        .clamp(30.0, 42.0)
        .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(alignment: Alignment.centerLeft, child: pill),
        const SizedBox(height: 10),
        Semantics(
          header: true,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: titleSize,
              height: 1.06,
              letterSpacing: -titleSize * 0.03,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: AppColors.slate,
          ),
        ),
      ],
    );
  }
}

/// Bandeau d'erreur affiché au-dessus du bouton d'envoi.
class RegistrationAlertBanner extends StatelessWidget {
  const RegistrationAlertBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.errorTint,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x33E24B4B)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: AppColors.errorDeep,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.errorDeep,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Phrase centrée avec un lien, en bas du formulaire.
class RegistrationFooterLink extends StatelessWidget {
  const RegistrationFooterLink({
    required this.prompt,
    required this.linkLabel,
    required this.onTap,
    super.key,
  });

  final String prompt;
  final String linkLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$prompt ',
          style: const TextStyle(fontSize: 14, color: AppColors.slate),
        ),
        JoynTextLink(label: linkLabel, onTap: onTap),
      ],
    );
  }
}

/// Panneau blanc du formulaire : en-tête, puis contenu centré (560 px max).
class RegistrationFormPanel extends StatelessWidget {
  const RegistrationFormPanel({
    required this.compact,
    required this.loginPrompt,
    required this.children,
    super.key,
  });

  final bool compact;
  final String loginPrompt;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      constraints: BoxConstraints(
        minHeight: screenHeight > 24 ? screenHeight - 24 : 0,
      ),
      padding: compact
          ? const EdgeInsets.fromLTRB(18, 20, 18, 28)
          : const EdgeInsets.fromLTRB(48, 28, 48, 40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(compact ? 24 : 32),
      ),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RegistrationFormHeader(compact: compact, loginPrompt: loginPrompt),
            const SizedBox(height: 28),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mise en page des écrans d'inscription : formulaire à gauche,
/// aperçu en direct à droite (masqué sous [previewBreakpoint]).
class RegistrationSplitLayout extends StatelessWidget {
  const RegistrationSplitLayout({
    required this.form,
    required this.preview,
    this.previewBreakpoint = 1120,
    super.key,
  });

  final Widget form;
  final Widget preview;
  final double previewBreakpoint;

  @override
  Widget build(BuildContext context) {
    final showPreview = MediaQuery.sizeOf(context).width >= previewBreakpoint;

    if (!showPreview) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: form,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 115, child: SingleChildScrollView(child: form)),
          const SizedBox(width: 12),
          Expanded(flex: 100, child: preview),
        ],
      ),
    );
  }
}
