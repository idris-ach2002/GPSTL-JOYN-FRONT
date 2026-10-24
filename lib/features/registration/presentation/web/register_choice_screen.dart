import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/components/joyn_logo.dart';
import 'package:joyn_front/design_system/theme/joyn_material_theme.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/registration/domain/account_type.dart';
import 'package:joyn_front/features/registration/presentation/web/widgets/choice_illustrations.dart';
import 'package:joyn_front/features/registration/presentation/web/widgets/register_choice_card.dart';
import 'package:joyn_front/features/registration/presentation/web/widgets/registration_backdrop.dart';

/// Écran 02a — Inscription, étape 1 sur 2 : choix du type de compte.
class RegisterChoiceScreen extends StatefulWidget {
  const RegisterChoiceScreen({super.key});

  @override
  State<RegisterChoiceScreen> createState() => _RegisterChoiceScreenState();
}

class _RegisterChoiceScreenState extends State<RegisterChoiceScreen> {
  AccountType _selected = AccountType.student;

  void _continue() {
    switch (_selected) {
      case AccountType.student:
        context.go(AppRoutes.candidateRegister);
      case AccountType.company:
        context.go(AppRoutes.recruiterRegister);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 640;

    return JoynMaterialScope(
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final density = _Density.of(constraints.maxHeight, compact);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(0.0, constraints.maxHeight - 24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(compact ? 24 : 32),
                    child: RegistrationBackdrop(
                      child: Padding(
                        padding: compact
                            ? const EdgeInsets.fromLTRB(18, 20, 18, 28)
                            : EdgeInsets.fromLTRB(
                                40,
                                density.outerTop,
                                40,
                                density.outerBottom,
                              ),
                        child: Column(
                          children: [
                            _Header(compact: compact),
                            SizedBox(height: density.gap),
                            _Intro(width: width, density: density),
                            SizedBox(height: density.gap),
                            _ChoiceCards(
                              density: density,
                              selected: _selected,
                              onSelected: (type) =>
                                  setState(() => _selected = type),
                            ),
                            SizedBox(height: density.gap),
                            FilledButton.icon(
                              key: const ValueKey('register-continue'),
                              style: JoynButtonStyles.large.merge(
                                JoynButtonStyles.trailingIcon,
                              ),
                              onPressed: _continue,
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: Text(
                                _selected == AccountType.student
                                    ? 'Continuer comme étudiant·e'
                                    : 'Continuer comme entreprise',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.compact});

  final bool compact;

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
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: JoynLogo(onDark: true),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!compact) ...[
              Text(
                'Déjà un compte ?',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.skyMist),
              ),
              const SizedBox(width: 12),
            ],
            OutlinedButton(
              style: JoynButtonStyles.outlinedOnDark,
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.width, required this.density});

  final double width;
  final _Density density;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleSize = (width * 0.052)
        .clamp(34.0, density.maxTitleSize)
        .toDouble();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Column(
        children: [
          Semantics(
            header: true,
            child: Text.rich(
              const TextSpan(
                text: 'Bienvenue sur Joyn',
                children: [
                  TextSpan(
                    text: '.',
                    style: TextStyle(color: AppColors.orangeLight),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: textTheme.displayLarge?.copyWith(
                fontSize: titleSize,
                height: 1.0,
                letterSpacing: -titleSize * 0.05,
                color: AppColors.white,
              ),
            ),
          ),
          SizedBox(height: density.introSpacing),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Text(
              "Étudiant·e en recherche d'alternance ou entreprise qui recrute : chaque profil a son espace.",
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: density.subtitleSize,
                color: AppColors.skyMist,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCards extends StatelessWidget {
  const _ChoiceCards({
    required this.density,
    required this.selected,
    required this.onSelected,
  });

  final _Density density;
  final AccountType selected;
  final ValueChanged<AccountType> onSelected;

  @override
  Widget build(BuildContext context) {
    final student = RegisterChoiceCard(
      key: const ValueKey('choice-student'),
      selected: selected == AccountType.student,
      onSelected: () => onSelected(AccountType.student),
      illustration: const StudentChoiceIllustration(),
      illustrationHeight: density.illustrationHeight,
      showBenefits: density.showBenefits,
      tagLabel: 'Étudiant·e',
      tagIcon: Icons.school_outlined,
      tint: AppColors.skyTint,
      tintForeground: AppColors.navy,
      title: 'Je cherche une alternance',
      description: 'Swipe des offres compatibles avec ta formation, ton rythme et tes technos.',
      benefits: const [
        'Gratuit, pour toujours',
        'Profil prêt en 2 minutes grâce à ton CV',
        'Un score de compatibilité sur chaque offre',
      ],
    );

    final company = RegisterChoiceCard(
      key: const ValueKey('choice-company'),
      selected: selected == AccountType.company,
      onSelected: () => onSelected(AccountType.company),
      illustration: const CompanyChoiceIllustration(),
      illustrationHeight: density.illustrationHeight,
      showBenefits: density.showBenefits,
      tagLabel: 'Entreprise',
      tagIcon: Icons.apartment_outlined,
      tint: AppColors.orangeTint,
      tintForeground: AppColors.orangeDeep,
      title: 'Je recrute des alternant·e·s',
      description: 'Recevez des profils compatibles avec votre poste, votre rythme et votre localisation.',
      benefits: const [
        'Paiement à l’annonce, sans abonnement',
        'Entreprise vérifiée grâce au SIRET',
        'Vos alternants cooptent leurs successeurs',
      ],
    );

    return ConstrainedBox(
      // Deux cartes à peu près carrées : leur largeur suit leur hauteur.
      constraints: BoxConstraints(maxWidth: density.cardMaxWidth * 2 + 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [student, const SizedBox(height: 24), company],
            );
          }
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: student),
                const SizedBox(width: 24),
                Expanded(child: company),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Tailles de l'écran selon la hauteur disponible : sur un écran
/// d'ordinateur courant, tout tient sans défilement.
class _Density {
  const _Density({
    required this.outerTop,
    required this.outerBottom,
    required this.gap,
    required this.introSpacing,
    required this.maxTitleSize,
    required this.subtitleSize,
    required this.illustrationHeight,
    required this.showBenefits,
    required this.cardMaxWidth,
  });

  /// Fenêtre haute (≥ 980 px) : mise en page aérée.
  static const _roomy = _Density(
    outerTop: 26,
    outerBottom: 36,
    gap: 32,
    introSpacing: 14,
    maxTitleSize: 62,
    subtitleSize: 18,
    illustrationHeight: 180,
    showBenefits: true,
    cardMaxWidth: 440,
  );

  /// Fenêtre moyenne (≥ 760 px) : écran d’ordinateur courant.
  static const _medium = _Density(
    outerTop: 20,
    outerBottom: 24,
    gap: 22,
    introSpacing: 10,
    maxTitleSize: 50,
    subtitleSize: 16,
    illustrationHeight: 140,
    showBenefits: true,
    cardMaxWidth: 400,
  );

  /// Fenêtre basse : les avantages des cartes sont masqués.
  static const _tight = _Density(
    outerTop: 16,
    outerBottom: 20,
    gap: 16,
    introSpacing: 8,
    maxTitleSize: 42,
    subtitleSize: 15,
    illustrationHeight: 112,
    showBenefits: false,
    cardMaxWidth: 330,
  );

  /// Sur mobile, la page défile de toute façon : on garde tout le contenu.
  static const _mobile = _Density(
    outerTop: 20,
    outerBottom: 28,
    gap: 28,
    introSpacing: 12,
    maxTitleSize: 44,
    subtitleSize: 16,
    illustrationHeight: 180,
    showBenefits: true,
    cardMaxWidth: 480,
  );

  static _Density of(double height, bool compact) {
    if (compact) return _mobile;
    if (height >= 980) return _roomy;
    if (height >= 760) return _medium;
    return _tight;
  }

  final double outerTop;
  final double outerBottom;
  final double gap;
  final double introSpacing;
  final double maxTitleSize;
  final double subtitleSize;
  final double illustrationHeight;
  final bool showBenefits;

  /// Largeur maximale d'une carte de choix.
  final double cardMaxWidth;
}
