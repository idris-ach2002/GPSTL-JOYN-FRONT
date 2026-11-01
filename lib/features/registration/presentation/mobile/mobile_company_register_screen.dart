import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../data/registration_repository.dart';
import '../controllers/company_register_controller.dart';
import '../shared/company_register_form.dart';
import 'mobile_register_header.dart';

/// Inscription mobile, étape 2 : espace entreprise.
class MobileCompanyRegisterScreen extends StatefulWidget {
  const MobileCompanyRegisterScreen({super.key});

  @override
  State<MobileCompanyRegisterScreen> createState() =>
      _MobileCompanyRegisterScreenState();
}

class _MobileCompanyRegisterScreenState
    extends State<MobileCompanyRegisterScreen> {
  late final CompanyRegisterController _form;
  final _siret = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _form = CompanyRegisterController(
      repository: context.read<RegistrationRepository>(),
    );
  }

  @override
  void dispose() {
    _form.dispose();
    _siret.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _searchCompany() {
    FocusScope.of(context).unfocus();
    _form.searchCompany();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final created = await _form.submit();
    if (!mounted || !created) return;
    await context.read<AuthController>().restoreSession();
    if (!mounted) return;
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return JoynMaterialScope(
      child: MobileAppSurface(
        backgroundColor: const Color(0xFFF7F8F2),
        child: ListenableBuilder(
          listenable: _form,
          builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: MobileRegisterHeader(
                    onBack: () => context.go(AppRoutes.register),
                    stepLabel: 'Étape 2 sur 2 · Entreprise',
                    stepColor: AppColors.orangeTint,
                    title: 'Créez votre espace entreprise.',
                    subtitle: 'Votre SIRET suffit pour retrouver l’entreprise. Vos besoins viendront juste après.',
                  ),
                ),
                const SizedBox(height: 22),
                CompanyRegisterForm(
                  form: _form,
                  siret: _siret,
                  firstName: _firstName,
                  lastName: _lastName,
                  phone: _phone,
                  email: _email,
                  password: _password,
                  compact: true,
                  onSearchCompany: _searchCompany,
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
