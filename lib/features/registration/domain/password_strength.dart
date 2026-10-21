/// Une règle de mot de passe et son état.
class PasswordRule {
  const PasswordRule(this.label, {required this.satisfied});

  final String label;
  final bool satisfied;
}

/// Évaluation de la robustesse d'un mot de passe, de 0 (vide) à 4.
class PasswordStrength {
  const PasswordStrength._({
    required this.score,
    required this.rules,
    required this.meetsRequirements,
  });

  factory PasswordStrength.evaluate(String password) {
    final longEnough = password.length >= 8;
    final hasUppercase = RegExp('[A-Z]').hasMatch(password);
    final hasDigit = RegExp('[0-9]').hasMatch(password);
    final hasSymbol = RegExp('[^A-Za-z0-9]').hasMatch(password);

    final rules = [
      PasswordRule('8 caractères', satisfied: longEnough),
      PasswordRule('1 majuscule', satisfied: hasUppercase),
      PasswordRule('1 chiffre', satisfied: hasDigit),
      PasswordRule('1 symbole', satisfied: hasSymbol),
    ];

    var score = rules.where((rule) => rule.satisfied).length;
    // Un mot de passe trop court reste « trop faible », quelles que soient
    // les autres règles respectées.
    if (!longEnough && score > 1) score = 1;
    if (password.isNotEmpty && score < 1) score = 1;
    if (password.isEmpty) score = 0;

    return PasswordStrength._(
      score: score,
      rules: rules,
      meetsRequirements: longEnough && hasUppercase && hasDigit,
    );
  }

  /// 0 = vide, 1 = trop faible, 2 = moyen, 3 = bon, 4 = excellent.
  final int score;
  final List<PasswordRule> rules;

  /// Minimum exigé pour créer le compte : 8 caractères, 1 majuscule, 1 chiffre.
  final bool meetsRequirements;

  String get label => const ['', 'Trop faible', 'Moyen', 'Bon', 'Excellent'][score];
}
