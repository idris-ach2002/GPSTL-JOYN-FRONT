import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../data/registration_repository.dart';
import '../controllers/student_register_controller.dart';

class MobileStudentRegisterScreen extends StatefulWidget {
  const MobileStudentRegisterScreen({super.key});

  @override
  State<MobileStudentRegisterScreen> createState() =>
      _MobileStudentRegisterScreenState();
}

class _MobileStudentRegisterScreenState
    extends State<MobileStudentRegisterScreen> {
  late final StudentRegisterController _form;
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _form = StudentRegisterController(
      repository: context.read<RegistrationRepository>(),
    );
  }

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
    await context.read<AuthController>().restoreSession();
    if (!mounted) return;
    context.go(AppRoutes.candidateOnboarding);
  }

  @override
  Widget build(BuildContext context) {
    return MobileAppSurface(
      child: ListenableBuilder(
        listenable: _form,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MobileRegisterHeader(
                onBack: () => context.go(AppRoutes.register),
              ),
              const SizedBox(height: 30),
              const _StepPill(label: 'Étape 2 sur 2 · Candidat'),
              const SizedBox(height: 16),
              const Text(
                'Crée ton compte.',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 31,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Quelques informations et ton profil JOYN peut commencer à matcher.',
                style: TextStyle(
                  color: AppColors.slate,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 26),
              MobileField(
                label: 'Prénom',
                hintText: 'Alex',
                controller: _firstName,
                onChanged: _form.updateFirstName,
              ),
              _FieldError(
                _form.visibleErrorFor(StudentRegisterField.firstName),
              ),
              const SizedBox(height: 14),
              MobileField(
                label: 'Nom',
                hintText: 'Dupont',
                controller: _lastName,
                onChanged: _form.updateLastName,
              ),
              _FieldError(_form.visibleErrorFor(StudentRegisterField.lastName)),
              const SizedBox(height: 14),
              MobileField(
                label: 'E-mail',
                hintText: 'alex@universite.fr',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                onChanged: _form.updateEmail,
              ),
              _FieldError(_form.visibleErrorFor(StudentRegisterField.email)),
              const SizedBox(height: 14),
              MobileField(
                label: 'Mot de passe',
                hintText: '8 caractères minimum',
                controller: _password,
                obscureText: !_form.passwordVisible,
                onChanged: _form.updatePassword,
                suffixIcon: IconButton(
                  onPressed: _form.togglePasswordVisibility,
                  icon: Icon(
                    _form.passwordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.navy,
                  ),
                ),
              ),
              _FieldError(_form.visibleErrorFor(StudentRegisterField.password)),
              const SizedBox(height: 10),
              _StrengthBar(value: _form.passwordStrength.score / 4),
              const SizedBox(height: 18),
              _CheckLine(
                value: _form.acceptedTerms,
                onChanged: _form.setAcceptedTerms,
                text: "J'accepte les conditions d'utilisation et la politique de confidentialité.",
              ),
              _FieldError(_form.visibleErrorFor(StudentRegisterField.terms)),
              _CheckLine(
                value: _form.weeklyDigest,
                onChanged: _form.setWeeklyDigest,
                text: 'Recevoir mes meilleurs matchs chaque semaine.',
              ),
              if (_form.submitError != null) ...[
                const SizedBox(height: 12),
                _ErrorCard(_form.submitError!),
              ],
              const SizedBox(height: 22),
              MobilePrimaryButton(
                label: 'Créer mon compte',
                loading: _form.isSubmitting,
                backgroundColor: AppColors.orange,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileRegisterHeader extends StatelessWidget {
  const _MobileRegisterHeader({required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton.filledTonal(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      const Spacer(),
      const MobileBrandMark(compact: true),
    ],
  );
}

class _StepPill extends StatelessWidget {
  const _StepPill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _FieldError extends StatelessWidget {
  const _FieldError(this.message);
  final String? message;
  @override
  Widget build(BuildContext context) => message == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            message!,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
}

class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.value});
  final double value;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(999),
    child: LinearProgressIndicator(
      minHeight: 5,
      value: value.clamp(0.0, 1.0).toDouble(),
      backgroundColor: const Color(0xFFE6EAE6),
      valueColor: const AlwaysStoppedAnimation(AppColors.orange),
    ),
  );
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({
    required this.value,
    required this.onChanged,
    required this.text,
  });
  final bool value;
  final ValueChanged<bool> onChanged;
  final String text;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => onChanged(!value),
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: (next) => onChanged(next ?? false),
            activeColor: AppColors.orange,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.slate,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFEEEE),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      message,
      style: const TextStyle(
        color: AppColors.error,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
