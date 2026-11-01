import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/material/joyn_chip_group.dart';
import 'package:joyn_front/design_system/theme/joyn_material_theme.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';
import 'package:joyn_front/features/registration/data/registration_repository.dart';
import 'package:joyn_front/features/registration/presentation/controllers/company_register_controller.dart';
import 'package:joyn_front/features/registration/presentation/shared/company_register_form.dart';
import 'package:joyn_front/features/registration/presentation/web/widgets/company_page_preview.dart';
import 'package:joyn_front/features/registration/presentation/web/widgets/registration_form_parts.dart';

/// Écran 02c — Inscription, étape 2 sur 2 : création de l'espace entreprise.
class CompanyRegisterScreen extends StatefulWidget {
  const CompanyRegisterScreen({super.key});

  @override
  State<CompanyRegisterScreen> createState() => _CompanyRegisterScreenState();
}

class _CompanyRegisterScreenState extends State<CompanyRegisterScreen> {
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
    final compact = MediaQuery.sizeOf(context).width < 640;

    return JoynMaterialScope(
      child: Scaffold(
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _form,
            builder: (context, _) => RegistrationSplitLayout(
              form: RegistrationFormPanel(
                compact: compact,
                loginPrompt: 'Déjà un compte ?',
                children: [
                  const RegistrationStepRow(),
                  const SizedBox(height: 22),
                  const RegistrationIntro(
                    chip: JoynInfoChip(
                      label: 'Compte entreprise',
                      icon: Icons.apartment_outlined,
                      background: AppColors.orangeTint,
                      foreground: AppColors.orangeDeep,
                    ),
                    title: 'Créez votre espace entreprise.',
                    subtitle: "Votre numéro SIRET suffit pour retrouver l'entreprise. Vous décrirez vos besoins juste après.",
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
                    compact: compact,
                    onSearchCompany: _searchCompany,
                    onSubmit: _submit,
                  ),
                  const SizedBox(height: 16),
                  RegistrationFooterLink(
                    prompt: 'Vous cherchez une alternance ?',
                    linkLabel: 'Créer un compte étudiant',
                    onTap: () => context.go(AppRoutes.candidateRegister),
                  ),
                ],
              ),
              preview: CompanyPagePreview(
                companyInitial: _form.companyInitial,
                companyName: _form.companyName,
                companyMeta: _form.companyMeta,
                verified: _form.companyFound,
                recruiterInitials: _form.recruiterInitials,
                recruiterName: _form.recruiterName,
                recruiterRole: _form.recruiterRole,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
