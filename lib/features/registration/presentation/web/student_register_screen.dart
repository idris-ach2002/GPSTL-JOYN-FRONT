import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/core/feedback/coming_soon.dart';
import 'package:joyn_front/design_system/material/joyn_chip_group.dart';
import 'package:joyn_front/design_system/theme/joyn_material_theme.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';
import 'package:joyn_front/features/registration/data/registration_repository.dart';
import 'package:joyn_front/features/registration/presentation/controllers/student_register_controller.dart';
import 'package:joyn_front/features/registration/presentation/shared/social_auth_buttons.dart';
import 'package:joyn_front/features/registration/presentation/shared/student_register_form.dart';
import 'package:joyn_front/features/registration/presentation/web/widgets/profile_live_preview.dart';
import 'package:joyn_front/features/registration/presentation/web/widgets/registration_form_parts.dart';

/// Écran 02b — Inscription, étape 2 sur 2 : création du compte étudiant.
class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
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
    final compact = MediaQuery.sizeOf(context).width < 640;

    return JoynMaterialScope(
      child: Scaffold(
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _form,
            builder: (context, _) => RegistrationSplitLayout(
              form: RegistrationFormPanel(
                compact: compact,
                loginPrompt: 'Déjà inscrit·e ?',
                children: [
                  const RegistrationStepRow(),
                  const SizedBox(height: 22),
                  const RegistrationIntro(
                    chip: JoynInfoChip(
                      label: 'Compte étudiant',
                      icon: Icons.school_outlined,
                      background: AppColors.skyTint,
                      foreground: AppColors.navy,
                    ),
                    title: 'Crée ton compte étudiant.',
                    subtitle: 'Moins de 2 minutes. Ton CV remplira le reste juste après.',
                  ),
                  const SizedBox(height: 22),
                  SocialAuthButtons(
                    onGoogle: () =>
                        showComingSoon(context, 'La connexion Google'),
                    onLinkedIn: () =>
                        showComingSoon(context, 'La connexion LinkedIn'),
                  ),
                  const SizedBox(height: 20),
                  const _OrDivider(),
                  const SizedBox(height: 20),
                  StudentRegisterForm(
                    form: _form,
                    firstName: _firstName,
                    lastName: _lastName,
                    email: _email,
                    password: _password,
                    stackNames: compact,
                    onSubmit: _submit,
                  ),
                  const SizedBox(height: 16),
                  RegistrationFooterLink(
                    prompt: 'Tu recrutes ?',
                    linkLabel: 'Créer un compte entreprise',
                    onTap: () => context.go(AppRoutes.recruiterRegister),
                  ),
                ],
              ),
              preview: ProfileLivePreview(
                initials: _form.initials,
                displayName: _form.displayName,
                verifiedStudent: _form.isStudentEmail,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou avec ton e-mail',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
