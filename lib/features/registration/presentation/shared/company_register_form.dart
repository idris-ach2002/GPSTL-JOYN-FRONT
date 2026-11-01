import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/material/joyn_chip_group.dart';
import '../../../../design_system/material/joyn_notice.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/company_options.dart';
import '../controllers/company_register_controller.dart';
import 'consent_checkbox.dart';
import 'password_strength_meter.dart';
import 'register_text_fields.dart';
import 'siret_field.dart';

/// Sections, consentement et bouton d'envoi de l'espace entreprise.
///
/// Commun au web et au mobile : seul l'habillage autour change.
class CompanyRegisterForm extends StatelessWidget {
  const CompanyRegisterForm({
    required this.form,
    required this.siret,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
    required this.onSearchCompany,
    required this.onSubmit,
    this.compact = false,
    super.key,
  });

  final CompanyRegisterController form;
  final TextEditingController siret;
  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController phone;
  final TextEditingController email;
  final TextEditingController password;
  final VoidCallback onSearchCompany;
  final VoidCallback onSubmit;

  /// Champs empilés et sections plus serrées (petits écrans).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormSectionCard(
            number: 1,
            title: 'Votre entreprise',
            badge: form.companyFound ? 'Pré-rempli grâce au SIRET' : null,
            compact: compact,
            children: [
              SiretField(
                controller: siret,
                onChanged: form.updateSiret,
                onSearch: onSearchCompany,
                isLoading: form.isLookingUp,
                company: form.company,
                errorText: form.visibleErrorFor(CompanyRegisterField.siret),
                showHint: form.showSiretHint,
                stacked: compact,
              ),
              const SizedBox(height: 20),
              const _GroupLabel("Secteur d'activité"),
              JoynChipGroup<String>.single(
                options: CompanyOptions.sectors,
                selected: form.sector,
                onSelected: form.setSector,
              ),
              const SizedBox(height: 18),
              const _GroupLabel("Taille de l'entreprise"),
              JoynChipGroup<String>.single(
                options: CompanyOptions.sizeRanges,
                selected: form.sizeRange,
                onSelected: form.setSizeRange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormSectionCard(
            number: 2,
            title: 'Vous',
            compact: compact,
            children: [
              FieldPair(
                stacked: compact,
                first: TextField(
                  key: const ValueKey('company-first-name'),
                  controller: firstName,
                  onChanged: form.updateFirstName,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.givenName],
                  decoration: InputDecoration(
                    labelText: 'Prénom',
                    hintText: 'Camille',
                    errorText: form.visibleErrorFor(
                      CompanyRegisterField.firstName,
                    ),
                  ),
                ),
                second: TextField(
                  key: const ValueKey('company-last-name'),
                  controller: lastName,
                  onChanged: form.updateLastName,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.familyName],
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    hintText: 'Roux',
                    errorText: form.visibleErrorFor(
                      CompanyRegisterField.lastName,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FieldPair(
                stacked: compact,
                first: DropdownMenu<String>(
                  key: const ValueKey('company-job-title'),
                  expandedInsets: EdgeInsets.zero,
                  requestFocusOnTap: false,
                  label: const Text('Fonction'),
                  hintText: 'Choisir votre fonction',
                  initialSelection: form.jobTitle,
                  errorText: form.visibleErrorFor(
                    CompanyRegisterField.jobTitle,
                  ),
                  onSelected: (value) {
                    if (value != null) form.setJobTitle(value);
                  },
                  dropdownMenuEntries: [
                    for (final title in CompanyOptions.jobTitles)
                      DropdownMenuEntry(value: title, label: title),
                  ],
                ),
                second: TextField(
                  key: const ValueKey('company-phone'),
                  controller: phone,
                  onChanged: form.updatePhone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9 +.]')),
                    LengthLimitingTextInputFormatter(17),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Téléphone (facultatif)',
                    hintText: '06 12 34 56 78',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    errorText: form.visibleErrorFor(CompanyRegisterField.phone),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _EmailField(form: form, controller: email),
              const SizedBox(height: 18),
              TextField(
                key: const ValueKey('company-password'),
                controller: password,
                onChanged: form.updatePassword,
                obscureText: !form.passwordVisible,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  hintText: '8 caractères minimum',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  errorText: form.visibleErrorFor(
                    CompanyRegisterField.password,
                  ),
                  suffixIcon: PasswordVisibilityButton(
                    visible: form.passwordVisible,
                    onPressed: form.togglePasswordVisibility,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PasswordStrengthMeter(strength: form.passwordStrength),
            ],
          ),
          const SizedBox(height: 16),
          ConsentCheckbox(
            key: const ValueKey('company-terms'),
            value: form.acceptedTerms,
            onChanged: form.setAcceptedTerms,
            errorText: form.visibleErrorFor(CompanyRegisterField.terms),
            // TODO : ouvrir les pages légales quand elles existeront.
            label: TextSpan(
              text: "J'accepte les ",
              children: [
                consentEmphasis("conditions d'utilisation"),
                const TextSpan(text: ' et les '),
                consentEmphasis('conditions de vente'),
                const TextSpan(
                  text:
                      ", et j'atteste agir pour le compte de cette entreprise.",
                ),
              ],
            ),
          ),
          if (form.showErrorSummary || form.submitError != null) ...[
            const SizedBox(height: 16),
            JoynNotice(
              tone: JoynNoticeTone.error,
              message: form.submitError ?? form.errorSummary,
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const ValueKey('company-submit'),
            style: JoynButtonStyles.accent
                .merge(JoynButtonStyles.large)
                .merge(JoynButtonStyles.trailingIcon),
            onPressed: form.isSubmitting ? null : onSubmit,
            icon: form.isSubmitting
                ? const ButtonProgress()
                : const Icon(Icons.arrow_forward_rounded),
            label: const Text("Créer l'espace entreprise"),
          ),
        ],
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.form, required this.controller});

  final CompanyRegisterController form;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final company = form.company;
    final (String? helper, TextStyle? helperStyle) = switch (form.emailHint) {
      CompanyEmailHint.matchesCompany => (
        'Domaine reconnu : ${company?.emailDomain} correspond à ${company?.displayName}.',
        successHelperStyle(context),
      ),
      CompanyEmailHint.personal => (
        'Adresse personnelle détectée : la vérification de votre entreprise prendra un peu plus de temps.',
        warningHelperStyle(context),
      ),
      CompanyEmailHint.advice => (
        'Utilisez votre adresse professionnelle : la vérification sera plus rapide.',
        null,
      ),
      CompanyEmailHint.none => (null, null),
    };

    return TextField(
      key: const ValueKey('company-email'),
      controller: controller,
      onChanged: form.updateEmail,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      decoration: InputDecoration(
        labelText: 'E-mail professionnel',
        hintText: 'prenom.nom@entreprise.fr',
        prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
        errorText: form.visibleErrorFor(CompanyRegisterField.email),
        helperText: helper,
        helperStyle: helperStyle,
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

/// Section numérotée du formulaire, dans une [Card].
class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    required this.number,
    required this.title,
    required this.children,
    this.badge,
    this.compact = false,
    super.key,
  });

  final int number;
  final String title;
  final String? badge;
  final bool compact;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final badge = this.badge;

    return Card(
      color: AppColors.surfaceSubtle,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.track),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.navy,
                  child: Text(
                    '$number',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                  ),
                ),
                if (badge != null && !compact)
                  Text(
                    badge,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.successDeep,
                      letterSpacing: 0,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }
}
