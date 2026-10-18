/// Validateurs de formulaires, avec messages d'erreur en français.
///
/// Chaque validateur retourne `null` si la valeur est valide, sinon le
/// message à afficher sous le champ. Compatibles avec `TextFormField.validator`.
abstract final class Validators {
  static final RegExp _emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _letterRegExp = RegExp(r'[A-Za-zÀ-ÿ]');
  static final RegExp _digitRegExp = RegExp(r'\d');

  static const int passwordMinLength = 8;

  /// Règles affichées sous le champ mot de passe à l'inscription.
  static const String passwordRulesHint =
      '8 caractères minimum, avec au moins une lettre et un chiffre.';

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Saisis ton adresse e-mail.';
    if (!_emailRegExp.hasMatch(email)) return 'Adresse e-mail invalide.';
    return null;
  }

  /// Mot de passe à la connexion : on vérifie seulement qu'il est rempli
  /// (les règles de complexité ne s'appliquent qu'à la création).
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Saisis ton mot de passe.';
    return null;
  }

  /// Nouveau mot de passe (inscription, réinitialisation).
  static String? newPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Choisis un mot de passe.';
    if (password.length < passwordMinLength) {
      return 'Le mot de passe doit contenir au moins $passwordMinLength caractères.';
    }
    if (!_letterRegExp.hasMatch(password)) {
      return 'Le mot de passe doit contenir au moins une lettre.';
    }
    if (!_digitRegExp.hasMatch(password)) {
      return 'Le mot de passe doit contenir au moins un chiffre.';
    }
    return null;
  }

  /// Confirmation : doit être identique au mot de passe retourné par [original].
  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) {
      if (value == null || value.isEmpty) return 'Confirme ton mot de passe.';
      if (value != original()) return 'Les mots de passe ne correspondent pas.';
      return null;
    };
  }
}
