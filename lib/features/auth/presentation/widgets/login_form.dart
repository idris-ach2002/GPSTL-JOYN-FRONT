import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/joyn_button.dart';
import '../../../../core/widgets/joyn_text_field.dart';
import '../auth_controller.dart';
import 'auth_error_banner.dart';
import 'social_auth_buttons.dart';

/// Formulaire de connexion (e-mail + mot de passe).
///
/// La redirection après succès n'est pas gérée ici : le routeur écoute
/// l'`AuthController` et envoie automatiquement vers l'accueil.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = true;

  /// Passe à `true` après la première tentative : les erreurs se mettent
  /// ensuite à jour pendant la saisie.
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthController>();
    if (auth.isLoading) return;

    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    await auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );
  }

  void _showComingSoon(String provider) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('La connexion avec $provider sera bientôt disponible.'),
        ),
      );
  }

  void _goToForgotPassword() {
    context.read<AuthController>().clearError();
    context.go(AppRoutes.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return AutofillGroup(
      child: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Content de te revoir.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              'Connecte-toi pour retrouver tes matchs, tes messages et '
              'tes entretiens.',
              style: AppTextStyles.muted,
            ),
            const SizedBox(height: AppSpacing.xl),

            SocialAuthButtons(
              onGoogle: () => _showComingSoon('Google'),
              onLinkedIn: () => _showComingSoon('LinkedIn'),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _OrDivider(),
            const SizedBox(height: AppSpacing.lg),

            JoynTextField(
              label: 'E-mail',
              controller: _emailController,
              hintText: 'prenom.nom@exemple.fr',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
            ),
            const SizedBox(height: 20),
            JoynTextField(
              label: 'Mot de passe',
              controller: _passwordController,
              isPassword: true,
              hintText: 'Ton mot de passe',
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: Validators.loginPassword,
              onFieldSubmitted: (_) => _submit(),
              trailingLabel: TextButton(
                onPressed: _goToForgotPassword,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 32),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _RememberMeCheckbox(
              value: _rememberMe,
              onChanged: (value) => setState(() => _rememberMe = value),
            ),

            if (auth.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              AuthErrorBanner(message: auth.errorMessage!),
            ],

            const SizedBox(height: AppSpacing.lg),
            JoynButton(
              label: 'Se connecter',
              icon: Icons.arrow_forward_rounded,
              isLoading: auth.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// Séparateur « Ou avec ton e-mail ».
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Ou avec ton e-mail', style: AppTextStyles.caption),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}

class _RememberMeCheckbox extends StatelessWidget {
  const _RememberMeCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (checked) => onChanged(checked ?? false),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: const Text('Se souvenir de moi', style: AppTextStyles.muted),
        ),
      ],
    );
  }
}
