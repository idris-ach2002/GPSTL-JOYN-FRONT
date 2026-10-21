import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/joyn_logo.dart';
import '../auth_controller.dart';
import '../widgets/auth_error_banner.dart';

/// Connexion pensée spécifiquement pour Android/iOS.
///
/// Le formulaire partage le même [AuthController] que l'expérience web, mais
/// la composition visuelle est indépendante de la landing et des écrans
/// desktop.
class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _entrance;

  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
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

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final animation = reduceMotion
        ? const AlwaysStoppedAnimation<double>(1.0)
        : CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: FadeTransition(
            opacity: animation,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: 24 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _MobileAuthHero(),
                  Transform.translate(
                    offset: Offset(0, 18 * (1 - animation.value)),
                    child: _LoginSheet(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      rememberMe: _rememberMe,
                      obscurePassword: _obscurePassword,
                      submitted: _submitted,
                      onRememberChanged: (value) {
                        setState(() => _rememberMe = value);
                      },
                      onTogglePassword: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onSubmit: _submit,
                      onGoogle: () => _showComingSoon('Google'),
                      onLinkedIn: () => _showComingSoon('LinkedIn'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileAuthHero extends StatelessWidget {
  const _MobileAuthHero();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 360;
    final heroHeight = compact
        ? (width * .72).clamp(220.0, 250.0).toDouble()
        : (width * .78).clamp(250.0, 330.0).toDouble();

    return Container(
      height: heroHeight,
      margin: EdgeInsets.fromLTRB(compact ? 10 : 14, 12, compact ? 10 : 14, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF001A34), AppColors.navy, Color(0xFF0B3762)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: .16),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(child: _HeroGrid()),
          Positioned(
            left: compact ? 16 : 24,
            top: compact ? 16 : 22,
            child: Hero(
              tag: 'joyn-mobile-brand',
              child: Material(
                color: Colors.transparent,
                child: JoynLogo(
                  size: compact ? 32 : 36,
                  showWordmark: !compact,
                  wordmarkColor: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            right: compact ? 16 : 24,
            top: compact ? 17 : 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: .16)),
              ),
              child: const Text(
                '92 % MATCH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .3,
                ),
              ),
            ),
          ),
          Positioned(
            left: compact ? 14 : 24,
            right: compact ? 14 : 24,
            bottom: compact ? 14 : 22,
            child: _MiniMatchPreview(compact: compact),
          ),
        ],
      ),
    );
  }
}

class _HeroGrid extends StatelessWidget {
  const _HeroGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _HeroGridPainter());
  }
}

class _HeroGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .055)
      ..strokeWidth = 1;
    const gap = 44.0;
    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniMatchPreview extends StatelessWidget {
  const _MiniMatchPreview({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 40 : 48,
            height: compact ? 40 : 48,
            decoration: BoxDecoration(
              color: AppColors.skySoft,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.code_rounded,
              color: AppColors.navy,
              size: compact ? 20 : 24,
            ),
          ),
          SizedBox(width: compact ? 9 : 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Développeur Full-Stack',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: compact ? 13 : 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Nébula Pay · Paris · Alternance',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: compact ? 10 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 7 : 10),
          Container(
            width: compact ? 34 : 42,
            height: compact ? 34 : 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.coral,
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: compact ? 18 : 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginSheet extends StatelessWidget {
  const _LoginSheet({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.obscurePassword,
    required this.submitted,
    required this.onRememberChanged,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onGoogle,
    required this.onLinkedIn,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool obscurePassword;
  final bool submitted;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onSubmit;
  final VoidCallback onGoogle;
  final VoidCallback onLinkedIn;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    final compact = MediaQuery.sizeOf(context).width < 360;

    return Container(
      margin: EdgeInsets.fromLTRB(compact ? 10 : 14, 14, compact ? 10 : 14, 0),
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 22,
        compact ? 22 : 26,
        compact ? 16 : 22,
        compact ? 24 : 28,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: const Color(0xFFE4EBF0)),
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
              Text(
                'Content de te revoir.',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: compact ? 25 : 28,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Retrouve tes matchs, tes messages et tes entretiens.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              _MobileTextField(
                key: const ValueKey('mobile-login-email'),
                label: 'E-mail',
                controller: emailController,
                hintText: 'prenom.nom@exemple.fr',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              _MobileTextField(
                key: const ValueKey('mobile-login-password'),
                label: 'Mot de passe',
                controller: passwordController,
                hintText: 'Ton mot de passe',
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: Validators.loginPassword,
                onFieldSubmitted: (_) => onSubmit(),
                suffixIcon: IconButton(
                  tooltip: obscurePassword
                      ? 'Afficher le mot de passe'
                      : 'Masquer le mot de passe',
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 315;
                  final remember = _RememberControl(
                    value: rememberMe,
                    onChanged: onRememberChanged,
                  );
                  final forgot = TextButton(
                    key: const ValueKey('mobile-forgot-password'),
                    onPressed: () {
                      context.read<AuthController>().clearError();
                      context.go(AppRoutes.forgotPassword);
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [remember, forgot],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: remember),
                      forgot,
                    ],
                  );
                },
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 12),
                AuthErrorBanner(message: auth.errorMessage!),
              ],
              const SizedBox(height: 18),
              SizedBox(
                height: 56,
                child: FilledButton(
                  key: const ValueKey('mobile-login-submit'),
                  onPressed: auth.isLoading ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: auth.isLoading
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Se connecter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 22),
              const _OrDivider(),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final google = _SocialButton(
                    label: 'Google',
                    icon: 'G',
                    onPressed: onGoogle,
                  );
                  final linkedIn = _SocialButton(
                    label: 'LinkedIn',
                    icon: 'in',
                    onPressed: onLinkedIn,
                  );
                  if (constraints.maxWidth < 270) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [google, const SizedBox(height: 10), linkedIn],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: google),
                      const SizedBox(width: 10),
                      Expanded(child: linkedIn),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Pas encore de compte ?',
                    style: TextStyle(
                      color: AppColors.textMuted,
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

class _MobileTextField extends StatelessWidget {
  const _MobileTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          obscureText: obscureText,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF7F9FB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFDDE5EA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFDDE5EA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _RememberControl extends StatelessWidget {
  const _RememberControl({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Checkbox(
                value: value,
                onChanged: (checked) => onChanged(checked ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 7),
            const Flexible(
              child: Text(
                'Se souvenir de moi',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 260;
        return Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFDDE5EA))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
              child: Text(
                compact ? 'ou' : 'ou continuer avec',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFDDE5EA))),
          ],
        );
      },
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
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy,
        side: const BorderSide(color: Color(0xFFD8E1E7)),
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: label == 'LinkedIn'
                    ? const Color(0xFF0A66C2)
                    : const Color(0xFFF1F4F7),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                icon,
                style: TextStyle(
                  color: label == 'LinkedIn' ? Colors.white : AppColors.navy,
                  fontSize: label == 'LinkedIn' ? 10 : 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
