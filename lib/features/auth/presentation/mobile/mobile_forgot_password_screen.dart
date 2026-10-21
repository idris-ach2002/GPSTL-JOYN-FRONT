import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../auth_controller.dart';

class MobileForgotPasswordScreen extends StatefulWidget {
  const MobileForgotPasswordScreen({super.key});

  @override
  State<MobileForgotPasswordScreen> createState() =>
      _MobileForgotPasswordScreenState();
}

class _MobileForgotPasswordScreenState
    extends State<MobileForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await context.read<AuthController>().sendPasswordReset(_email.text.trim());
    if (mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    return MobileAppSurface(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => context.go(AppRoutes.login),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Spacer(),
                  const MobileBrandMark(compact: true),
                ],
              ),
              const SizedBox(height: 46),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 76,
                  height: 76,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE9E1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.orange,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Mot de passe oublié ?',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Entre ton e-mail et on t’envoie les instructions de réinitialisation.',
                style: TextStyle(
                  color: AppColors.slate,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              MobileField(
                label: 'E-mail',
                hintText: 'prenom.nom@exemple.fr',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              if (_sent) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6EF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Si ce compte existe, un e-mail vient d’être envoyé.',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              MobilePrimaryButton(
                label: 'Envoyer le lien',
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
