import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../data/registration_repository.dart';
import '../controllers/company_register_controller.dart';

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

  static const _roles = [
    'RH / Talent acquisition',
    'Manager',
    'Direction',
    'Autre',
  ];

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
    return MobileAppSurface(
      child: ListenableBuilder(
        listenable: _form,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => context.go(AppRoutes.register),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Spacer(),
                  const MobileBrandMark(compact: true),
                ],
              ),
              const SizedBox(height: 30),
              const _Pill(),
              const SizedBox(height: 16),
              const Text(
                'Crée ton espace entreprise.',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Retrouve ton entreprise puis configure ton accès recruteur.',
                style: TextStyle(
                  color: AppColors.slate,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: MobileField(
                      label: 'SIRET',
                      hintText: '123 456 789 00012',
                      controller: _siret,
                      keyboardType: TextInputType.number,
                      onChanged: _form.updateSiret,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: _form.isLookingUp ? null : _form.searchCompany,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.navy,
                      ),
                      child: _form.isLookingUp
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search_rounded),
                    ),
                  ),
                ],
              ),
              _Error(_form.visibleErrorFor(CompanyRegisterField.siret)),
              if (_form.companyFound) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6EF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _form.companyName,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              MobileField(
                label: 'Prénom',
                hintText: 'Camille',
                controller: _firstName,
                onChanged: _form.updateFirstName,
              ),
              _Error(_form.visibleErrorFor(CompanyRegisterField.firstName)),
              const SizedBox(height: 14),
              MobileField(
                label: 'Nom',
                hintText: 'Martin',
                controller: _lastName,
                onChanged: _form.updateLastName,
              ),
              _Error(_form.visibleErrorFor(CompanyRegisterField.lastName)),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _form.jobTitle,
                isExpanded: true,
                decoration: _dropdownDecoration('Fonction'),
                items: _roles
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) _form.setJobTitle(value);
                },
              ),
              _Error(_form.visibleErrorFor(CompanyRegisterField.jobTitle)),
              const SizedBox(height: 14),
              MobileField(
                label: 'Téléphone',
                hintText: '06 12 34 56 78',
                controller: _phone,
                keyboardType: TextInputType.phone,
                onChanged: _form.updatePhone,
              ),
              _Error(_form.visibleErrorFor(CompanyRegisterField.phone)),
              const SizedBox(height: 14),
              MobileField(
                label: 'E-mail professionnel',
                hintText: 'camille@entreprise.fr',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                onChanged: _form.updateEmail,
              ),
              _Error(_form.visibleErrorFor(CompanyRegisterField.email)),
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
                  ),
                ),
              ),
              _Error(_form.visibleErrorFor(CompanyRegisterField.password)),
              const SizedBox(height: 14),
              InkWell(
                onTap: () => _form.setAcceptedTerms(!_form.acceptedTerms),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _form.acceptedTerms,
                      onChanged: (v) => _form.setAcceptedTerms(v ?? false),
                      activeColor: AppColors.orange,
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          "J'accepte les conditions d'utilisation et la politique de confidentialité.",
                          style: TextStyle(
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
              _Error(_form.visibleErrorFor(CompanyRegisterField.terms)),
              if (_form.submitError != null) ...[
                const SizedBox(height: 10),
                _ErrorCard(_form.submitError!),
              ],
              const SizedBox(height: 22),
              MobilePrimaryButton(
                label: 'Créer mon espace',
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

  InputDecoration _dropdownDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFF4F6F3),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE4E8E3)),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill();
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9E1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Étape 2 sur 2 · Entreprise',
        style: TextStyle(
          color: AppColors.navy,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _Error extends StatelessWidget {
  const _Error(this.message);
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
