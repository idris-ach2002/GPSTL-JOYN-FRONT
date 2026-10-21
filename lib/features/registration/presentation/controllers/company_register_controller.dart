import 'package:flutter/foundation.dart';

import '../../data/mock_registration_repository.dart';
import '../../data/registration_repository.dart';
import '../../domain/company_account_draft.dart';
import '../../domain/company_info.dart';
import '../../domain/email_rules.dart';
import '../../domain/password_strength.dart';
import '../../domain/siret.dart';

/// Champs du formulaire entreprise qui peuvent être en erreur.
enum CompanyRegisterField {
  siret,
  firstName,
  lastName,
  jobTitle,
  phone,
  email,
  password,
  terms,
}

/// État de la recherche d'entreprise par SIRET.
enum SiretLookupStatus { idle, loading, found, notFound }

/// Indication affichée sous l'e-mail professionnel.
enum CompanyEmailHint {
  /// Le domaine correspond à l'entreprise retrouvée.
  matchesCompany,

  /// Messagerie grand public : vérification plus longue.
  personal,

  /// Conseil par défaut.
  advice,

  /// Rien à afficher (l'erreur du champ prend la place).
  none,
}

/// État et règles du formulaire « Créez votre espace entreprise ».
class CompanyRegisterController extends ChangeNotifier {
  CompanyRegisterController({RegistrationRepository? repository})
    : _repository = repository ?? MockRegistrationRepository();

  final RegistrationRepository _repository;

  String _siret = '';
  SiretLookupStatus _lookupStatus = SiretLookupStatus.idle;
  CompanyInfo? _company;
  bool _siretSearchAttempted = false;
  int _lookupId = 0;

  String? _sector;
  String? _sizeRange;
  String _firstName = '';
  String _lastName = '';
  String? _jobTitle;
  String _phone = '';
  String _email = '';
  String _password = '';
  bool _passwordVisible = false;
  bool _acceptedTerms = false;

  bool _submitAttempted = false;
  bool _isSubmitting = false;
  String? _submitError;
  bool _disposed = false;

  // ---------------------------------------------------------------------------
  // Lecture
  // ---------------------------------------------------------------------------

  /// SIRET tel qu'affiché, avec espaces.
  String get siret => _siret;
  SiretLookupStatus get lookupStatus => _lookupStatus;
  bool get isLookingUp => _lookupStatus == SiretLookupStatus.loading;
  CompanyInfo? get company => _company;
  bool get companyFound => _company != null;

  String? get sector => _sector;
  String? get sizeRange => _sizeRange;
  String? get jobTitle => _jobTitle;
  bool get passwordVisible => _passwordVisible;
  bool get acceptedTerms => _acceptedTerms;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;

  PasswordStrength get passwordStrength => PasswordStrength.evaluate(_password);

  CompanyEmailHint get emailHint {
    if (visibleErrorFor(CompanyRegisterField.email) != null) {
      return CompanyEmailHint.none;
    }
    final company = _company;
    final domain = EmailRules.domainOf(_email);
    if (company != null && domain == company.emailDomain) {
      return CompanyEmailHint.matchesCompany;
    }
    if (EmailRules.isPersonalEmail(_email)) return CompanyEmailHint.personal;
    return CompanyEmailHint.advice;
  }

  /// Message d'erreur d'un champ, qu'il soit affiché ou non.
  String? errorFor(CompanyRegisterField field) {
    return switch (field) {
      CompanyRegisterField.siret => _siretError(),
      CompanyRegisterField.firstName =>
        _firstName.trim().isEmpty ? 'Indiquez votre prénom.' : null,
      CompanyRegisterField.lastName =>
        _lastName.trim().isEmpty ? 'Indiquez votre nom.' : null,
      CompanyRegisterField.jobTitle =>
        _jobTitle == null ? 'Indiquez votre fonction.' : null,
      CompanyRegisterField.phone => _phoneError(),
      CompanyRegisterField.email =>
        EmailRules.isValid(_email)
            ? null
            : 'Saisissez une adresse e-mail valide.',
      CompanyRegisterField.password =>
        passwordStrength.meetsRequirements
            ? null
            : 'Au moins 8 caractères, dont une majuscule et un chiffre.',
      CompanyRegisterField.terms =>
        _acceptedTerms
            ? null
            : 'Acceptez les conditions pour créer votre espace.',
    };
  }

  /// Message à afficher : après une tentative d'envoi (ou de recherche,
  /// pour le SIRET).
  String? visibleErrorFor(CompanyRegisterField field) {
    if (field == CompanyRegisterField.siret) {
      if (isLookingUp) return null;
      return _submitAttempted || _siretSearchAttempted ? errorFor(field) : null;
    }
    return _submitAttempted ? errorFor(field) : null;
  }

  /// Astuce SIRET : seulement tant qu'il n'y a ni résultat ni erreur visible.
  bool get showSiretHint =>
      !companyFound &&
      !isLookingUp &&
      visibleErrorFor(CompanyRegisterField.siret) == null;

  int get errorCount =>
      CompanyRegisterField.values.where((f) => errorFor(f) != null).length;

  bool get isValid => errorCount == 0;

  bool get showErrorSummary => _submitAttempted && !isValid;

  String get errorSummary => errorCount > 1
      ? 'Il reste $errorCount points à corriger avant de créer votre espace.'
      : 'Il reste 1 point à corriger avant de créer votre espace.';

  // Aperçu « Votre page entreprise ».

  String get companyInitial => _company?.initial ?? '?';
  String get companyName => _company?.displayName ?? 'Votre entreprise';

  String get companyMeta {
    final parts = <String>[
      _sector ?? 'Secteur',
      '${_sizeRange ?? '…'} salariés',
      if (_company != null) _company!.city,
    ];
    return parts.join(' · ');
  }

  String get recruiterInitials {
    final first = _firstName.trim();
    final last = _lastName.trim();
    final value =
        '${first.isEmpty ? '' : first[0]}${last.isEmpty ? '' : last[0]}'
            .toUpperCase();
    return value.isEmpty ? '?' : value;
  }

  String get recruiterName {
    final first = _firstName.trim();
    final last = _lastName.trim();
    if (first.isEmpty) return 'Votre nom';
    if (last.isEmpty) return first;
    return '$first ${last[0].toUpperCase()}.';
  }

  String get recruiterRole => _jobTitle ?? 'Votre fonction';

  // ---------------------------------------------------------------------------
  // Modifications
  // ---------------------------------------------------------------------------

  /// Une nouvelle saisie annule le résultat de la recherche précédente.
  void updateSiret(String value) {
    final formatted = Siret.format(value);
    if (formatted == _siret) return;
    _update(() {
      _siret = formatted;
      _lookupId++;
      _lookupStatus = SiretLookupStatus.idle;
      _company = null;
      _siretSearchAttempted = false;
    });
  }

  /// Recherche l'entreprise. Ignore les réponses devenues obsolètes.
  Future<void> searchCompany() async {
    if (isLookingUp) return;
    _siretSearchAttempted = true;
    if (!Siret.hasValidLength(_siret)) {
      _notify();
      return;
    }

    final requestId = ++_lookupId;
    _lookupStatus = SiretLookupStatus.loading;
    _company = null;
    _notify();

    final result = await _repository.findCompanyBySiret(Siret.digitsOf(_siret));
    if (requestId != _lookupId) return;

    _company = result;
    _lookupStatus = result == null
        ? SiretLookupStatus.notFound
        : SiretLookupStatus.found;
    if (result != null) {
      _sector = result.sector ?? _sector;
      _sizeRange = result.sizeRange ?? _sizeRange;
    }
    _notify();
  }

  void setSector(String value) => _update(() => _sector = value);
  void setSizeRange(String value) => _update(() => _sizeRange = value);
  void updateFirstName(String value) => _update(() => _firstName = value);
  void updateLastName(String value) => _update(() => _lastName = value);
  void setJobTitle(String value) => _update(() => _jobTitle = value);
  void updatePhone(String value) => _update(() => _phone = value);
  void updateEmail(String value) => _update(() => _email = value);
  void updatePassword(String value) => _update(() => _password = value);
  void togglePasswordVisibility() =>
      _update(() => _passwordVisible = !_passwordVisible);
  void setAcceptedTerms(bool value) => _update(() => _acceptedTerms = value);

  /// Valide puis envoie le formulaire. Renvoie `true` si l'espace est créé.
  Future<bool> submit() async {
    if (_isSubmitting) return false;

    _submitAttempted = true;
    _submitError = null;
    if (!isValid) {
      _notify();
      return false;
    }

    _isSubmitting = true;
    _notify();
    try {
      await _repository.createCompanyAccount(_toDraft());
      return true;
    } on RegistrationException catch (error) {
      _submitError = error.message;
      return false;
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  String? _siretError() {
    if (companyFound) return null;
    if (!Siret.hasValidLength(_siret)) return 'Un numéro SIRET compte 14 chiffres.';
    if (_lookupStatus == SiretLookupStatus.notFound) {
      return 'Aucune entreprise ne correspond à ce SIRET. Vérifiez le numéro.';
    }
    return 'Lancez la recherche pour retrouver votre entreprise.';
  }

  String? _phoneError() {
    final digits = _phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    final valid = (digits.length == 10 && digits.startsWith('0')) ||
        (digits.length == 11 && digits.startsWith('33'));
    return valid ? null : 'Saisissez un numéro à 10 chiffres, par exemple 06 12 34 56 78.';
  }

  CompanyAccountDraft _toDraft() {
    final phone = _phone.trim();
    return CompanyAccountDraft(
      siret: Siret.digitsOf(_siret),
      sector: _sector,
      sizeRange: _sizeRange,
      firstName: _firstName.trim(),
      lastName: _lastName.trim(),
      jobTitle: _jobTitle ?? '',
      email: _email.trim(),
      password: _password,
      acceptedTerms: _acceptedTerms,
      phone: phone.isEmpty ? null : phone,
    );
  }

  void _update(VoidCallback change) {
    change();
    _submitError = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
