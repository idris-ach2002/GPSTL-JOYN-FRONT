import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/joyn_button.dart';
import '../../../core/widgets/joyn_logo.dart';
import '../../../core/widgets/joyn_text_field.dart';
import 'auth_controller.dart';
import 'widgets/auth_error_banner.dart';

/// Écran « Mot de passe oublié » (route `/forgot-password`).
///
/// Après l'envoi, affiche une confirmation volontairement neutre : on ne
/// révèle pas si l'adresse correspond à un compte.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitted = false;

  /// Adresse à laquelle le lien a été envoyé (`null` tant que non envoyé).
  String? _sentTo;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthController>();
    if (auth.isLoading) return;

    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final success = await auth.sendPasswordReset(email);
    if (success && mounted) setState(() => _sentTo = email);
  }

  void _backToLogin() {
    context.read<AuthController>().clearError();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: JoynLogo(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (_sentTo == null) _buildForm() else _buildConfirmation(),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: TextButton.icon(
                        onPressed: _backToLogin,
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Retour à la connexion'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final auth = context.watch<AuthController>();

    return Form(
      key: _formKey,
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mot de passe oublié ?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          const Text(
            'Indique l’adresse e-mail de ton compte : on t’envoie un lien pour '
            'choisir un nouveau mot de passe.',
            style: AppTextStyles.muted,
          ),
          const SizedBox(height: AppSpacing.lg),
          JoynTextField(
            label: 'E-mail',
            controller: _emailController,
            hintText: 'prenom.nom@exemple.fr',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            validator: Validators.email,
            onFieldSubmitted: (_) => _submit(),
          ),
          if (auth.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            AuthErrorBanner(message: auth.errorMessage!),
          ],
          const SizedBox(height: AppSpacing.lg),
          JoynButton(
            label: 'Envoyer le lien',
            icon: Icons.arrow_forward_rounded,
            isLoading: auth.isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.coralSoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.coral,
            size: 32,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Vérifie ta boîte mail',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Si un compte existe pour $_sentTo, tu vas recevoir un e-mail avec '
          'un lien pour réinitialiser ton mot de passe.',
          textAlign: TextAlign.center,
          style: AppTextStyles.muted,
        ),
      ],
    );
  }
}
