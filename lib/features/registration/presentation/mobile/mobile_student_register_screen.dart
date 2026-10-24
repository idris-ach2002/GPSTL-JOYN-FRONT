import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../data/registration_repository.dart';
import '../controllers/student_register_controller.dart';
import '../shared/student_register_form.dart';
import 'mobile_register_header.dart';

/// Inscription mobile, étape 2 : compte étudiant.
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
    return JoynMaterialScope(
      child: MobileAppSurface(
        backgroundColor: const Color(0xFFF7F8F2),
        child: ListenableBuilder(
          listenable: _form,
          builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MobileRegisterHeader(
                  onBack: () => context.go(AppRoutes.register),
                  stepLabel: 'Étape 2 sur 2 · Étudiant·e',
                  title: 'Crée ton compte.',
                  subtitle: 'Quelques informations et ton profil JOYN peut commencer à matcher.',
                ),
                const SizedBox(height: 26),
                StudentRegisterForm(
                  form: _form,
                  firstName: _firstName,
                  lastName: _lastName,
                  email: _email,
                  password: _password,
                  stackNames: true,
                  onSubmit: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
