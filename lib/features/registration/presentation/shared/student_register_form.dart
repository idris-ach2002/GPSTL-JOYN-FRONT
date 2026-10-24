import 'package:flutter/material.dart';

import '../../../../design_system/material/joyn_notice.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../controllers/student_register_controller.dart';
import 'consent_checkbox.dart';
import 'password_strength_meter.dart';
import 'register_text_fields.dart';

/// Champs, consentements et bouton d'envoi du compte étudiant.
///
/// Commun au web et au mobile : seul l'habillage autour change.
class StudentRegisterForm extends StatelessWidget {
  const StudentRegisterForm({
    required this.form,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.onSubmit,
    this.stackNames = false,
    super.key,
  });

  final StudentRegisterController form;
  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController email;
  final TextEditingController password;
  final VoidCallback onSubmit;

  /// Prénom et nom l'un sous l'autre (petits écrans).
  final bool stackNames;

  @override
  Widget build(BuildContext context) {
    final emailError = form.visibleErrorFor(StudentRegisterField.email);

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FieldPair(
            stacked: stackNames,
            first: TextField(
              key: const ValueKey('register-first-name'),
              controller: firstName,
              onChanged: form.updateFirstName,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.givenName],
              decoration: InputDecoration(
                labelText: 'Prénom',
                hintText: 'Yasmine',
                errorText: form.visibleErrorFor(StudentRegisterField.firstName),
              ),
            ),
            second: TextField(
              key: const ValueKey('register-last-name'),
              controller: lastName,
              onChanged: form.updateLastName,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.familyName],
              decoration: InputDecoration(
                labelText: 'Nom',
                hintText: 'Kacimi',
                errorText: form.visibleErrorFor(StudentRegisterField.lastName),
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            key: const ValueKey('register-email'),
            controller: email,
            onChanged: form.updateEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: 'E-mail',
              hintText: 'prenom.nom@ecole.fr',
              prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
              errorText: emailError,
              helperText: form.isStudentEmail
                  ? 'Adresse étudiante détectée : ton profil aura le badge vérifié.'
                  : 'Astuce : avec ton e-mail étudiant, ton profil obtient le badge vérifié.',
              helperStyle: form.isStudentEmail
                  ? successHelperStyle(context)
                  : null,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            key: const ValueKey('register-password'),
            controller: password,
            onChanged: form.updatePassword,
            obscureText: !form.passwordVisible,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              hintText: '8 caractères minimum',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              errorText: form.visibleErrorFor(StudentRegisterField.password),
              suffixIcon: PasswordVisibilityButton(
                visible: form.passwordVisible,
                onPressed: form.togglePasswordVisibility,
              ),
            ),
          ),
          const SizedBox(height: 12),
          PasswordStrengthMeter(strength: form.passwordStrength),
          const SizedBox(height: 16),
          ConsentCheckbox(
            key: const ValueKey('register-terms'),
            value: form.acceptedTerms,
            onChanged: form.setAcceptedTerms,
            errorText: form.visibleErrorFor(StudentRegisterField.terms),
            // TODO : ouvrir les pages légales quand elles existeront.
            label: TextSpan(
              text: "J'accepte les ",
              children: [
                consentEmphasis("conditions d'utilisation"),
                const TextSpan(text: ' et la '),
                consentEmphasis('politique de confidentialité'),
                const TextSpan(text: ' de Joyn.'),
              ],
            ),
          ),
          ConsentCheckbox(
            value: form.weeklyDigest,
            onChanged: form.setWeeklyDigest,
            label: const TextSpan(
              text: 'Recevoir chaque semaine les nouvelles offres compatibles par e-mail.',
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
            key: const ValueKey('register-submit'),
            style: JoynButtonStyles.accent
                .merge(JoynButtonStyles.large)
                .merge(JoynButtonStyles.trailingIcon),
            onPressed: form.isSubmitting ? null : onSubmit,
            icon: form.isSubmitting
                ? const ButtonProgress()
                : const Icon(Icons.arrow_forward_rounded),
            label: const Text('Créer mon compte'),
          ),
        ],
      ),
    );
  }
}
