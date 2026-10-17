import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/feedback/coming_soon.dart';
import '../../../../design_system/components/joyn_button.dart';
import '../../../../design_system/components/joyn_logo.dart';
import '../../../../design_system/components/joyn_pill.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../domain/account_type.dart';
import '../widgets/choice_illustrations.dart';
import '../widgets/register_choice_card.dart';
import '../widgets/registration_backdrop.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
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
                          : const EdgeInsets.fromLTRB(40, 26, 40, 56),
                      child: Column(
                        children: [
                          _Header(compact: compact),
                          SizedBox(height: compact ? 32 : 44),
                          _Intro(width: width),
                          SizedBox(height: compact ? 32 : 44),
                          _ChoiceCards(
                            selected: _selected,
                            onSelected: (type) =>
                                setState(() => _selected = type),
                          ),
                          SizedBox(height: compact ? 32 : 44),
                          JoynButton(
                            key: const ValueKey('register-continue'),
                            label: _selected == AccountType.student
                                ? 'Continuer comme étudiant·e'
                                : 'Continuer comme entreprise',
                            trailingIcon: Icons.arrow_forward_rounded,
                            height: 58,
                            fontSize: 17,
                            onPressed: _continue,
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
        Semantics(
          link: true,
          label: "Joyn, retour à l'accueil",
          excludeSemantics: true,
          child: InkWell(
            onTap: () => context.go(AppRoutes.landing),
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
              const Text(
                'Déjà un compte ?',
                style: TextStyle(fontSize: 14, color: AppColors.skyMist),
              ),
              const SizedBox(width: 12),
            ],
            JoynButton(
              label: 'Se connecter',
              variant: JoynButtonVariant.outlineOnDark,
              height: 42,
              fontSize: 14,
              onPressed: () => showComingSoon(context, 'La connexion'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final titleSize = (width * 0.052).clamp(36.0, 68.0).toDouble();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Column(
        children: [
          const JoynPill(
            label: 'Inscription · étape 1 sur 2',
            background: Color(0x1FFFFFFF),
            foreground: AppColors.white,
            borderColor: Color(0x38FFFFFF),
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          ),
          const SizedBox(height: 16),
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
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontSize: titleSize,
                height: 1.0,
                letterSpacing: -titleSize * 0.05,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: const Text(
              "Étudiant·e en recherche d'alternance ou entreprise qui recrute : chaque profil a son espace.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
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
  const _ChoiceCards({required this.selected, required this.onSelected});

  final AccountType selected;
  final ValueChanged<AccountType> onSelected;

  @override
  Widget build(BuildContext context) {
    final student = RegisterChoiceCard(
      key: const ValueKey('choice-student'),
      selected: selected == AccountType.student,
      onSelected: () => onSelected(AccountType.student),
      illustration: const StudentChoiceIllustration(),
      tagLabel: 'Étudiant·e',
      tagIcon: Icons.school_outlined,
      tint: AppColors.skyTint,
      tintForeground: AppColors.navy,
      title: 'Je cherche une alternance',
      description:
          'Swipe des offres compatibles avec ta formation, ton rythme et tes technos.',
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
      tagLabel: 'Entreprise',
      tagIcon: Icons.apartment_outlined,
      tint: AppColors.orangeTint,
      tintForeground: AppColors.orangeDeep,
      title: 'Je recrute des alternant·e·s',
      description:
          'Recevez des profils compatibles avec votre poste, votre rythme et votre localisation.',
      benefits: const [
        'Paiement à l’annonce, sans abonnement',
        'Entreprise vérifiée grâce au SIRET',
        'Vos alternants cooptent leurs successeurs',
      ],
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1080),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 824) {
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
