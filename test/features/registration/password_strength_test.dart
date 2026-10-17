import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/registration/domain/password_strength.dart';

void main() {
  group('PasswordStrength', () {
    test('un mot de passe vide a un score de 0 et pas de libellé', () {
      final strength = PasswordStrength.evaluate('');
      expect(strength.score, 0);
      expect(strength.label, isEmpty);
      expect(strength.meetsRequirements, isFalse);
    });

    test('un mot de passe court reste « Trop faible »', () {
      final strength = PasswordStrength.evaluate('Ab1!');
      expect(strength.score, 1);
      expect(strength.label, 'Trop faible');
    });

    test('8 caractères + majuscule + chiffre suffisent pour valider', () {
      final strength = PasswordStrength.evaluate('Joynjoyn1');
      expect(strength.meetsRequirements, isTrue);
      expect(strength.score, 3);
      expect(strength.label, 'Bon');
    });

    test('les 4 règles respectées donnent « Excellent »', () {
      final strength = PasswordStrength.evaluate('Joyn2026!');
      expect(strength.score, 4);
      expect(strength.label, 'Excellent');
      expect(strength.rules.every((rule) => rule.satisfied), isTrue);
    });

    test('sans chiffre, le mot de passe est refusé', () {
      expect(PasswordStrength.evaluate('Joynjoyn!').meetsRequirements, isFalse);
    });
  });
}
