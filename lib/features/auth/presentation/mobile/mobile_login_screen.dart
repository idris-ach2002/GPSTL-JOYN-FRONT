import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../auth_controller.dart';
import '../shared/auth_error_banner.dart';

/// Connexion native JOYN. Aucun composant de landing web n'est utilisé ici.
class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = true;
  bool _obscure = true;
  bool _submitted = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthController>();
    if (auth.isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    await auth.signIn(
      email: _email.text.trim(),
      password: _password.text,
      rememberMe: _remember,
    );
  }

  void _soon(String provider) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$provider arrive bientôt.')));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return MobileAppSurface(
      systemUiOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          children: [
            const _LoginHero(),
            _LoginBody(
              formKey: _formKey,
              email: _email,
              password: _password,
              remember: _remember,
              obscure: _obscure,
              submitted: _submitted,
              onRemember: (value) => setState(() => _remember = value),
              onToggleObscure: () => setState(() => _obscure = !_obscure),
              onSubmit: _submit,
              onGoogle: () => _soon('Google'),
              onLinkedIn: () => _soon('LinkedIn'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 350;
    return Container(
      width: double.infinity,
      height: compact ? 245 : 285,
      padding: EdgeInsets.fromLTRB(
        compact ? 20 : 24,
        20,
        compact ? 20 : 24,
        24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00172D), AppColors.navy, Color(0xFF0C3A66)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(38)),
      ),
      child: Stack(
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: MobileBrandMark(onDark: true, compact: true),
          ),
          Positioned(
            top: compact ? 62 : 68,
            left: 0,
            right: 0,
            child: const _HeroMatchCard(),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Text(
              'Ton prochain match\ncommence ici.',
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 22 : 25,
                height: 1.03,
                fontWeight: FontWeight.w900,
                letterSpacing: -.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMatchCard extends StatelessWidget {
  const _HeroMatchCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFFFE8DF),
                child: Icon(Icons.business_rounded, color: AppColors.orange),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Candidate',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Full-Stack · Paris',
                      style: TextStyle(
                        color: AppColors.slate,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                radius: 23,
                backgroundColor: AppColors.navy,
                child: Text(
                  '92%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody({
    required this.formKey,
    required this.email,
    required this.password,
    required this.remember,
    required this.obscure,
    required this.submitted,
    required this.onRemember,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onGoogle,
    required this.onLinkedIn,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool remember;
  final bool obscure;
  final bool submitted;
  final ValueChanged<bool> onRemember;
  final VoidCallback onToggleObscure;
  final Future<void> Function() onSubmit;
  final VoidCallback onGoogle;
  final VoidCallback onLinkedIn;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 350;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 24,
        26,
        compact ? 18 : 24,
        34,
      ),
      child: AutofillGroup(
        child: Form(
          key: formKey,
          autovalidateMode: submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Content de te revoir',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connecte-toi pour retrouver tes matchs et tes messages.',
                style: TextStyle(
                  color: AppColors.slate,
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              MobileField(
                key: const ValueKey('mobile-login-email'),
                label: 'E-mail',
                hintText: 'prenom.nom@exemple.fr',
                controller: email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              MobileField(
                key: const ValueKey('mobile-login-password'),
                label: 'Mot de passe',
                hintText: 'Ton mot de passe',
                controller: password,
                obscureText: obscure,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: Validators.loginPassword,
                onFieldSubmitted: (_) => onSubmit(),
                suffixIcon: IconButton(
                  onPressed: onToggleObscure,
                  icon: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Checkbox(
                    value: remember,
                    onChanged: (value) => onRemember(value ?? false),
                    activeColor: AppColors.orange,
                    visualDensity: VisualDensity.compact,
                  ),
                  const Expanded(
                    child: Text(
                      'Se souvenir de moi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.slate,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('mobile-forgot-password'),
                    onPressed: () {
                      context.read<AuthController>().clearError();
                      context.go(AppRoutes.forgotPassword);
                    },
                    child: const Text(
                      'Mot oublié ?',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 8),
                AuthErrorBanner(message: auth.errorMessage!),
              ],
              const SizedBox(height: 14),
              MobilePrimaryButton(
                key: const ValueKey('mobile-login-submit'),
                label: 'Se connecter',
                loading: auth.isLoading,
                onPressed: onSubmit,
              ),
              const SizedBox(height: 22),
              const _DividerLabel(),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final buttons = [
                    _SocialButton(
                      label: 'Google',
                      icon: 'G',
                      onPressed: onGoogle,
                    ),
                    _SocialButton(
                      label: 'LinkedIn',
                      icon: 'in',
                      onPressed: onLinkedIn,
                    ),
                  ];
                  if (constraints.maxWidth < 300) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buttons[0],
                        const SizedBox(height: 10),
                        buttons[1],
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: buttons[0]),
                      const SizedBox(width: 10),
                      Expanded(child: buttons[1]),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Pas encore de compte ?',
                    style: TextStyle(
                      color: AppColors.placeholder,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('mobile-create-account'),
                    onPressed: () => context.go(AppRoutes.register),
                    child: const Text(
                      'Créer un compte',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFE1E6E1))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou continuer avec',
            style: TextStyle(
              color: AppColors.placeholder,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFE1E6E1))),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final String icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: Color(0xFFD6DDD6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: TextStyle(
                color: icon == 'G'
                    ? const Color(0xFF4285F4)
                    : const Color(0xFF0A66C2),
                fontSize: icon == 'G' ? 18 : 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
