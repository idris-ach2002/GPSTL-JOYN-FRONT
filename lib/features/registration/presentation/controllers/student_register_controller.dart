import 'package:flutter/foundation.dart';

import '../../data/mock_registration_repository.dart';
import '../../data/registration_repository.dart';
import '../../domain/email_rules.dart';
import '../../domain/password_strength.dart';
import '../../domain/student_account_draft.dart';

/// Champs du formulaire qui peuvent être en erreur.
enum StudentRegisterField { firstName, lastName, email, password, terms }

/// État et règles du formulaire « Crée ton compte étudiant ».
///
/// Les erreurs ne s'affichent qu'après une première tentative d'envoi,
/// pour ne pas accueillir l'étudiant·e avec un formulaire tout rouge.
class StudentRegisterController extends ChangeNotifier {
  StudentRegisterController({RegistrationRepository? repository})
    : _repository = repository ?? MockRegistrationRepository();

  final RegistrationRepository _repository;

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  bool _passwordVisible = false;
  bool _acceptedTerms = false;
  bool _weeklyDigest = false;

  bool _submitAttempted = false;
  bool _isSubmitting = false;
  String? _submitError;
  bool _disposed = false;

  // ---------------------------------------------------------------------------
  // Lecture
  // ---------------------------------------------------------------------------

  bool get passwordVisible => _passwordVisible;
  bool get acceptedTerms => _acceptedTerms;
  bool get weeklyDigest => _weeklyDigest;
  bool get isSubmitting => _isSubmitting;

  /// Erreur renvoyée par le serveur (adresse déjà utilisée…).
  String? get submitError => _submitError;

  PasswordStrength get passwordStrength => PasswordStrength.evaluate(_password);

  bool get isStudentEmail => EmailRules.looksLikeStudentEmail(_email);

  /// Initiales pour l'avatar de l'aperçu, « ? » tant que rien n'est saisi.
  String get initials {
    final first = _firstName.trim();
    final last = _lastName.trim();
    final value =
        '${first.isEmpty ? '' : first[0]}${last.isEmpty ? '' : last[0]}'
            .toUpperCase();
    return value.isEmpty ? '?' : value;
  }

  /// Nom affiché dans l'aperçu : « Yasmine K. ».
  String get displayName {
    final first = _firstName.trim();
    final last = _lastName.trim();
    if (first.isEmpty) return 'Ton prénom';
    if (last.isEmpty) return first;
    return '$first ${last[0].toUpperCase()}.';
  }

  /// Message d'erreur d'un champ, qu'il soit affiché ou non.
  String? errorFor(StudentRegisterField field) {
    return switch (field) {
      StudentRegisterField.firstName =>
        _firstName.trim().isEmpty ? 'Indique ton prénom.' : null,
      StudentRegisterField.lastName =>
        _lastName.trim().isEmpty ? 'Indique ton nom.' : null,
      StudentRegisterField.email =>
        EmailRules.isValid(_email) ? null : 'Entre une adresse e-mail valide.',
      StudentRegisterField.password =>
        passwordStrength.meetsRequirements
            ? null
            : 'Ajoute au moins 8 caractères, une majuscule et un chiffre.',
      StudentRegisterField.terms =>
        _acceptedTerms ? null : 'Accepte les conditions pour créer ton compte.',
    };
  }

  /// Message d'erreur à afficher : seulement après une tentative d'envoi.
  String? visibleErrorFor(StudentRegisterField field) {
    return _submitAttempted ? errorFor(field) : null;
  }

  int get errorCount =>
      StudentRegisterField.values.where((f) => errorFor(f) != null).length;

  bool get isValid => errorCount == 0;

  bool get showErrorSummary => _submitAttempted && !isValid;

  String get errorSummary => errorCount > 1
      ? 'Il reste $errorCount points à corriger avant de créer ton compte.'
      : 'Il reste 1 point à corriger avant de créer ton compte.';

  // ---------------------------------------------------------------------------
  // Modifications
  // ---------------------------------------------------------------------------

  void updateFirstName(String value) => _update(() => _firstName = value);
  void updateLastName(String value) => _update(() => _lastName = value);
  void updateEmail(String value) => _update(() => _email = value);
  void updatePassword(String value) => _update(() => _password = value);

  void togglePasswordVisibility() =>
      _update(() => _passwordVisible = !_passwordVisible);

  void setAcceptedTerms(bool value) => _update(() => _acceptedTerms = value);
  void setWeeklyDigest(bool value) => _update(() => _weeklyDigest = value);

  /// Valide puis envoie le formulaire. Renvoie `true` si le compte est créé.
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
      await _repository.createStudentAccount(_toDraft());
      return true;
    } on RegistrationException catch (error) {
      _submitError = error.message;
      return false;
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  StudentAccountDraft _toDraft() {
    return StudentAccountDraft(
      firstName: _firstName.trim(),
      lastName: _lastName.trim(),
      email: _email.trim(),
      password: _password,
      acceptedTerms: _acceptedTerms,
      weeklyDigest: _weeklyDigest,
    );
  }

  void _update(VoidCallback change) {
    change();
    // Dès qu'on corrige un champ, l'erreur serveur n'a plus lieu d'être.
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
