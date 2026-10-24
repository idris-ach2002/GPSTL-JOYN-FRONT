import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/components/joyn_logo.dart';
import 'package:joyn_front/design_system/material/joyn_chip_group.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';

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
        Tooltip(
          message: kIsWeb ? "Retour à l'accueil" : 'Retour à la connexion',
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
              Text(loginPrompt, style: Theme.of(context).textTheme.bodySmall),
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Lien « ← Changer de profil », vers l'écran de choix du type de compte.
class RegistrationStepRow extends StatelessWidget {
  const RegistrationStepRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => context.go(AppRoutes.register),
        icon: const Icon(Icons.arrow_back_rounded, size: 18),
        label: const Text('Changer de profil'),
      ),
    );
  }
}

/// Puce, titre et phrase d'introduction d'un formulaire d'inscription.
class RegistrationIntro extends StatelessWidget {
  const RegistrationIntro({
    required this.chip,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final JoynInfoChip chip;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleSize = (MediaQuery.sizeOf(context).width * 0.03)
        .clamp(30.0, 42.0)
        .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(alignment: Alignment.centerLeft, child: chip),
        const SizedBox(height: 10),
        Semantics(
          header: true,
          child: Text(
            title,
            style: textTheme.displaySmall?.copyWith(
              fontSize: titleSize,
              letterSpacing: -titleSize * 0.03,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.slate),
        ),
      ],
    );
  }
}

/// Phrase centrée avec un lien ([TextButton]), en bas du formulaire.
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
        Text(prompt, style: Theme.of(context).textTheme.bodySmall),
        TextButton(onPressed: onTap, child: Text(linkLabel)),
      ],
    );
  }
}

/// Panneau blanc du formulaire ([Card]) : en-tête puis contenu centré.
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

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(compact ? 24 : 32),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: math.max(0.0, screenHeight - 24),
        ),
        child: Padding(
          padding: compact
              ? const EdgeInsets.fromLTRB(18, 20, 18, 28)
              : const EdgeInsets.fromLTRB(48, 28, 48, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RegistrationFormHeader(
                compact: compact,
                loginPrompt: loginPrompt,
              ),
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
      ),
    );
  }
}

/// Formulaire à gauche, aperçu en direct à droite (masqué sous
/// [previewBreakpoint]).
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
