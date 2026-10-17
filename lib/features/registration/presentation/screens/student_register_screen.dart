import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/feedback/coming_soon.dart';
import '../../../../design_system/components/joyn_button.dart';
import '../../../../design_system/components/joyn_field_message.dart';
import '../../../../design_system/components/joyn_pill.dart';
import '../../../../design_system/components/joyn_text_field.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../controllers/student_register_controller.dart';
import '../widgets/consent_checkbox.dart';
import '../widgets/password_strength_meter.dart';
import '../widgets/profile_live_preview.dart';
import '../widgets/registration_form_parts.dart';
import '../widgets/social_auth_buttons.dart';

/// Écran 02b — Inscription, étape 2 sur 2 : création du compte étudiant.
class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _form = StudentRegisterController();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _form.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final created = await _form.submit();
    if (!mounted || !created) return;
    context.go(AppRoutes.candidateOnboarding);
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 640;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _form,
          builder: (context, _) => RegistrationSplitLayout(
            form: _FormPanel(
              form: _form,
              compact: compact,
              firstName: _firstName,
              lastName: _lastName,
              email: _email,
              password: _password,
              onSubmit: _submit,
            ),
            preview: ProfileLivePreview(
              initials: _form.initials,
              displayName: _form.displayName,
              verifiedStudent: _form.isStudentEmail,
            ),
          ),
        ),
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.form,
    required this.compact,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.onSubmit,
  });

  final StudentRegisterController form;
  final bool compact;
  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController email;
  final TextEditingController password;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return RegistrationFormPanel(
      compact: compact,
      loginPrompt: 'Déjà inscrit·e ?',
      children: [
        const RegistrationStepRow(),
        const SizedBox(height: 22),
        const RegistrationIntro(
          pill: JoynPill(
            label: 'Compte étudiant',
            icon: Icons.school_outlined,
            background: AppColors.skyTint,
            foreground: AppColors.navy,
          ),
          title: 'Crée ton compte étudiant.',
          subtitle:
              'Moins de 2 minutes. Ton CV remplira le reste juste après.',
        ),
        const SizedBox(height: 22),
        SocialAuthButtons(
          onGoogle: () =>
              showComingSoon(context, 'La connexion Google'),
          onLinkedIn: () =>
              showComingSoon(context, 'La connexion LinkedIn'),
        ),
        const SizedBox(height: 22),
        const _OrDivider(),
        const SizedBox(height: 22),
        _NameFields(
          form: form,
          compact: compact,
          firstName: firstName,
          lastName: lastName,
        ),
        const SizedBox(height: 22),
        JoynTextField(
          key: const ValueKey('register-email'),
          label: 'E-mail',
          controller: email,
          onChanged: form.updateEmail,
          hintText: 'prenom.nom@ecole.fr',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          errorText: form.visibleErrorFor(
            StudentRegisterField.email,
          ),
          helper: _emailHelper(),
        ),
        const SizedBox(height: 22),
        JoynTextField(
          key: const ValueKey('register-password'),
          label: 'Mot de passe',
          controller: password,
          onChanged: form.updatePassword,
          hintText: '8 caractères minimum',
          obscureText: !form.passwordVisible,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          errorText: form.visibleErrorFor(
            StudentRegisterField.password,
          ),
          suffix: IconButton(
            tooltip: form.passwordVisible
                ? 'Masquer le mot de passe'
                : 'Afficher le mot de passe',
            onPressed: form.togglePasswordVisibility,
            icon: Icon(
              form.passwordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.slate,
              size: 20,
            ),
          ),
          helper: PasswordStrengthMeter(
            strength: form.passwordStrength,
          ),
        ),
        const SizedBox(height: 22),
        ConsentCheckbox(
          key: const ValueKey('register-terms'),
          value: form.acceptedTerms,
          onChanged: form.setAcceptedTerms,
          errorText: form.visibleErrorFor(
            StudentRegisterField.terms,
          ),
          // TODO: ouvrir les pages légales quand elles existeront.
          label: const TextSpan(
            text: "J'accepte les ",
            children: [
              TextSpan(
                text: "conditions d'utilisation",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
              TextSpan(text: ' et la '),
              TextSpan(
                text: 'politique de confidentialité',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
              TextSpan(text: ' de Joyn.'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ConsentCheckbox(
          value: form.weeklyDigest,
          onChanged: form.setWeeklyDigest,
          label: const TextSpan(
            text:
                'Recevoir chaque semaine les nouvelles offres compatibles par e-mail.',
          ),
        ),
        if (form.showErrorSummary || form.submitError != null) ...[
          const SizedBox(height: 22),
          RegistrationAlertBanner(
            message: form.submitError ?? form.errorSummary,
          ),
        ],
        const SizedBox(height: 22),
        JoynButton(
          key: const ValueKey('register-submit'),
          label: 'Créer mon compte',
          variant: JoynButtonVariant.accent,
          trailingIcon: Icons.arrow_forward_rounded,
          height: 56,
          expand: true,
          isLoading: form.isSubmitting,
          onPressed: onSubmit,
        ),
        const SizedBox(height: 22),
        RegistrationFooterLink(
          prompt: 'Tu recrutes ?',
          linkLabel: 'Créer un compte entreprise',
          onTap: () => context.go(AppRoutes.recruiterRegister),
        ),
      ],
    );
  }

  Widget? _emailHelper() {
    if (form.isStudentEmail) {
      return const JoynFieldMessage.success(
        'Adresse étudiante détectée : ton profil aura le badge vérifié.',
      );
    }
    if (form.visibleErrorFor(StudentRegisterField.email) != null) return null;
    return const JoynFieldMessage(
      'Astuce : avec ton e-mail étudiant, ton profil obtient le badge vérifié.',
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.lineSoft, height: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou avec ton e-mail',
            style: TextStyle(fontSize: 13, color: AppColors.slate),
          ),
        ),
        Expanded(child: Divider(color: AppColors.lineSoft, height: 1)),
      ],
    );
  }
}

class _NameFields extends StatelessWidget {
  const _NameFields({
    required this.form,
    required this.compact,
    required this.firstName,
    required this.lastName,
  });

  final StudentRegisterController form;
  final bool compact;
  final TextEditingController firstName;
  final TextEditingController lastName;

  @override
  Widget build(BuildContext context) {
    final first = JoynTextField(
      key: const ValueKey('register-first-name'),
      label: 'Prénom',
      controller: firstName,
      onChanged: form.updateFirstName,
      hintText: 'Yasmine',
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.givenName],
      errorText: form.visibleErrorFor(StudentRegisterField.firstName),
    );
    final last = JoynTextField(
      key: const ValueKey('register-last-name'),
      label: 'Nom',
      controller: lastName,
      onChanged: form.updateLastName,
      hintText: 'Kacimi',
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.familyName],
      errorText: form.visibleErrorFor(StudentRegisterField.lastName),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [first, const SizedBox(height: 22), last],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 14),
        Expanded(child: last),
      ],
    );
  }
}
