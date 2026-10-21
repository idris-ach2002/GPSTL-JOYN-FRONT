import 'package:flutter_test/flutter_test.dart';

import 'package:joyn_front/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('refuse une valeur vide', () {
      expect(Validators.email(''), 'Saisis ton adresse e-mail.');
      expect(Validators.email(null), 'Saisis ton adresse e-mail.');
    });

    test('refuse une adresse mal formée', () {
      expect(Validators.email('ariel@'), 'Adresse e-mail invalide.');
      expect(Validators.email('ariel.joyn.fr'), 'Adresse e-mail invalide.');
    });

    test('accepte une adresse valide, même entourée d’espaces', () {
      expect(Validators.email(' ariel.benatsi@gmail.com '), isNull);
    });
  });

  group('Validators.newPassword', () {
    test('exige 8 caractères minimum', () {
      expect(Validators.newPassword('abc1'), contains('8 caractères'));
    });

    test('exige au moins une lettre et un chiffre', () {
      expect(Validators.newPassword('12345678'), contains('une lettre'));
      expect(Validators.newPassword('abcdefgh'), contains('un chiffre'));
    });

    test('accepte un mot de passe conforme', () {
      expect(Validators.newPassword('Joyn2026'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    final validator = Validators.confirmPassword(() => 'Joyn2026');

    test('refuse une confirmation différente', () {
      expect(validator('Joyn2025'), 'Les mots de passe ne correspondent pas.');
    });

    test('accepte une confirmation identique', () {
      expect(validator('Joyn2026'), isNull);
    });
  });
}
