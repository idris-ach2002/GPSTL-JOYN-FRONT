import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../data/registration_repository.dart';
import '../../../../design_system/components/joyn_button.dart';
import '../../../../design_system/components/joyn_choice_chip.dart';
import '../../../../design_system/components/joyn_field_message.dart';
import '../../../../design_system/components/joyn_pill.dart';
import '../../../../design_system/components/joyn_select_field.dart';
import '../../../../design_system/components/joyn_text_field.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../domain/company_options.dart';
import '../controllers/company_register_controller.dart';
import '../widgets/company_page_preview.dart';
import '../widgets/consent_checkbox.dart';
import '../widgets/password_strength_meter.dart';
import '../widgets/registration_form_parts.dart';
import '../widgets/siret_field.dart';

/// Écran 02c — Inscription, étape 2 sur 2 : création de l'espace entreprise.
class CompanyRegisterScreen extends StatefulWidget {
  const CompanyRegisterScreen({super.key});

  @override
  State<CompanyRegisterScreen> createState() => _CompanyRegisterScreenState();
}

class _CompanyRegisterScreenState extends State<CompanyRegisterScreen> {
  late final CompanyRegisterController _form;

  final _siret = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _form = CompanyRegisterController(
      repository: context.read<RegistrationRepository>(),
    );
  }

  @override
  void dispose() {
    _form.dispose();
    _siret.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _searchCompany() {
    FocusScope.of(context).unfocus();
    _form.searchCompany();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final created = await _form.submit();
    if (!mounted || !created) return;

    await context.read<AuthController>().restoreSession();
    if (!mounted) return;
    context.go(AppRoutes.dashboard);
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
            form: RegistrationFormPanel(
              compact: compact,
              loginPrompt: 'Déjà un compte ?',
              children: [
                const RegistrationStepRow(),
                const SizedBox(height: 22),
                const RegistrationIntro(
                  pill: JoynPill(
                    label: 'Compte entreprise',
                    icon: Icons.apartment_outlined,
                    background: AppColors.orangeTint,
                    foreground: AppColors.orangeDeep,
                  ),
                  title: 'Créez votre espace entreprise.',
                  subtitle: "Votre numéro SIRET suffit pour retrouver l'entreprise. Vous décrirez vos besoins juste après.",
                ),
                const SizedBox(height: 22),
                _CompanySection(
                  form: _form,
                  siret: _siret,
                  onSearch: _searchCompany,
                ),
                const SizedBox(height: 16),
                _YouSection(
                  form: _form,
                  compact: compact,
                  firstName: _firstName,
                  lastName: _lastName,
                  phone: _phone,
                  email: _email,
                  password: _password,
                ),
                const SizedBox(height: 22),
                ConsentCheckbox(
                  key: const ValueKey('company-terms'),
                  value: _form.acceptedTerms,
                  onChanged: _form.setAcceptedTerms,
                  errorText: _form.visibleErrorFor(CompanyRegisterField.terms),
                  // TODO : ouvrir les pages légales quand elles existeront.
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
                      TextSpan(text: ' et les '),
                      TextSpan(
                        text: 'conditions de vente',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                      TextSpan(
                        text: ", et j'atteste agir pour le compte de cette entreprise.",
                      ),
                    ],
                  ),
                ),
                if (_form.showErrorSummary || _form.submitError != null) ...[
                  const SizedBox(height: 22),
                  RegistrationAlertBanner(
                    message: _form.submitError ?? _form.errorSummary,
                  ),
                ],
                const SizedBox(height: 22),
                JoynButton(
                  key: const ValueKey('company-submit'),
                  label: "Créer l'espace entreprise",
                  variant: JoynButtonVariant.accent,
                  trailingIcon: Icons.arrow_forward_rounded,
                  height: 56,
                  expand: true,
                  isLoading: _form.isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: 22),
                RegistrationFooterLink(
                  prompt: 'Vous cherchez une alternance ?',
                  linkLabel: 'Créer un compte étudiant',
                  onTap: () => context.go(AppRoutes.candidateRegister),
                ),
              ],
            ),
            preview: CompanyPagePreview(
              companyInitial: _form.companyInitial,
              companyName: _form.companyName,
              companyMeta: _form.companyMeta,
              verified: _form.companyFound,
              recruiterInitials: _form.recruiterInitials,
              recruiterName: _form.recruiterName,
              recruiterRole: _form.recruiterRole,
            ),
          ),
        ),
      ),
    );
  }
}

/// Encadré numéroté d'une partie du formulaire.
class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.number,
    required this.title,
    required this.children,
    this.badge,
  });

  final int number;
  final String title;
  final String? badge;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.track),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.navy,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              if (badge != null)
                Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.successDeep,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _CompanySection extends StatelessWidget {
  const _CompanySection({
    required this.form,
    required this.siret,
    required this.onSearch,
  });

  final CompanyRegisterController form;
  final TextEditingController siret;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return _FormSection(
      number: 1,
      title: 'Votre entreprise',
      badge: form.companyFound ? 'Pré-rempli grâce au SIRET' : null,
      children: [
        SiretField(
          controller: siret,
          onChanged: form.updateSiret,
          onSearch: onSearch,
          isLoading: form.isLookingUp,
          company: form.company,
          errorText: form.visibleErrorFor(CompanyRegisterField.siret),
          showHint: form.showSiretHint,
        ),
        const SizedBox(height: 18),
        _ChipGroup(
          label: "Secteur d'activité",
          options: CompanyOptions.sectors,
          selected: form.sector,
          onSelected: form.setSector,
        ),
        const SizedBox(height: 18),
        _ChipGroup(
          label: "Taille de l'entreprise",
          options: CompanyOptions.sizeRanges,
          selected: form.sizeRange,
          onSelected: form.setSizeRange,
        ),
      ],
    );
  }
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              JoynChoiceChip(
                label: option,
                height: 42,
                selected: option == selected,
                onTap: () => onSelected(option),
              ),
          ],
        ),
      ],
    );
  }
}

class _YouSection extends StatelessWidget {
  const _YouSection({
    required this.form,
    required this.compact,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
  });

  final CompanyRegisterController form;
  final bool compact;
  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController phone;
  final TextEditingController email;
  final TextEditingController password;

  Widget _pair(Widget first, Widget second) {
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [first, const SizedBox(height: 18), second],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 14),
        Expanded(child: second),
      ],
    );
  }

  Widget? _emailHelper() {
    final company = form.company;
    return switch (form.emailHint) {
      CompanyEmailHint.matchesCompany => JoynFieldMessage.success(
        'Domaine reconnu : ${company?.emailDomain} correspond à ${company?.displayName}.',
      ),
      CompanyEmailHint.personal => const _WarningNote(
        'Adresse personnelle détectée : la vérification de votre entreprise prendra un peu plus de temps.',
      ),
      CompanyEmailHint.advice => const JoynFieldMessage(
        'Utilisez votre adresse professionnelle : la vérification sera plus rapide.',
      ),
      CompanyEmailHint.none => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return _FormSection(
      number: 2,
      title: 'Vous',
      children: [
        _pair(
          JoynTextField(
            key: const ValueKey('company-first-name'),
            label: 'Prénom',
            controller: firstName,
            onChanged: form.updateFirstName,
            hintText: 'Camille',
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
            errorText: form.visibleErrorFor(CompanyRegisterField.firstName),
          ),
          JoynTextField(
            key: const ValueKey('company-last-name'),
            label: 'Nom',
            controller: lastName,
            onChanged: form.updateLastName,
            hintText: 'Roux',
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.familyName],
            errorText: form.visibleErrorFor(CompanyRegisterField.lastName),
          ),
        ),
        const SizedBox(height: 18),
        _pair(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              JoynSelectField<String>(
                label: 'Fonction',
                options: CompanyOptions.jobTitles,
                value: form.jobTitle,
                onChanged: form.setJobTitle,
                placeholder: 'Choisir votre fonction',
              ),
              if (form.visibleErrorFor(CompanyRegisterField.jobTitle)
                  case final error?) ...[
                const SizedBox(height: 7),
                JoynFieldMessage.error(error),
              ],
            ],
          ),
          JoynTextField(
            key: const ValueKey('company-phone'),
            label: 'Téléphone',
            labelSuffix: '(facultatif)',
            controller: phone,
            onChanged: form.updatePhone,
            hintText: '06 12 34 56 78',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9 +.]')),
              LengthLimitingTextInputFormatter(17),
            ],
            errorText: form.visibleErrorFor(CompanyRegisterField.phone),
          ),
        ),
        const SizedBox(height: 18),
        JoynTextField(
          key: const ValueKey('company-email'),
          label: 'E-mail professionnel',
          controller: email,
          onChanged: form.updateEmail,
          hintText: 'prenom.nom@entreprise.fr',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          errorText: form.visibleErrorFor(CompanyRegisterField.email),
          helper: _emailHelper(),
        ),
        const SizedBox(height: 18),
        JoynTextField(
          key: const ValueKey('company-password'),
          label: 'Mot de passe',
          controller: password,
          onChanged: form.updatePassword,
          hintText: '8 caractères minimum',
          obscureText: !form.passwordVisible,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          errorText: form.visibleErrorFor(CompanyRegisterField.password),
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
          helper: PasswordStrengthMeter(strength: form.passwordStrength),
        ),
      ],
    );
  }
}

class _WarningNote extends StatelessWidget {
  const _WarningNote(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warningTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: AppColors.warningDeep,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: AppColors.warningDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
