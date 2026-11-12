import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/admin_companies/domain/company_validators.dart';

void main() {
  group('SIRET', () {
    test('formatage 3-3-3-5 et 14 chiffres maximum', () {
      expect(
        CompanyValidators.formatSiret('73282932000074'),
        '732 829 320 00074',
      );
      expect(CompanyValidators.formatSiret('7328a2 93'), '732 829 3');
      expect(
        CompanyValidators.siretDigits('732829320000741234'),
        '73282932000074',
      );
    });

    test('un SIRET réel valide passe (clé de Luhn correcte)', () {
      expect(CompanyValidators.siretError('732 829 320 00074'), isNull);
    });

    test('mauvaise longueur ou mauvaise clé : erreur', () {
      expect(CompanyValidators.siretError(''), 'Indiquez le numéro SIRET.');
      expect(
        CompanyValidators.siretError('732 829 320'),
        'Un numéro SIRET compte 14 chiffres.',
      );
      expect(
        CompanyValidators.siretError('732 829 320 00075'),
        contains('clé de contrôle'),
      );
    });

    test('exception de La Poste (somme des chiffres multiple de 5)', () {
      expect(CompanyValidators.siretError('35600000000006'), isNull);
    });
  });

  group('site web', () {
    test('facultatif', () {
      expect(CompanyValidators.websiteError(''), isNull);
    });

    test('adresses valides et invalides', () {
      expect(CompanyValidators.websiteError('https://nebulapay.fr'), isNull);
      expect(CompanyValidators.websiteError('nebulapay.fr/carrieres'), isNull);
      expect(CompanyValidators.websiteError('pas une url'), isNotNull);
      expect(CompanyValidators.websiteError('https://localhost'), isNotNull);
    });

    test('ajoute https:// si besoin', () {
      expect(
        CompanyValidators.normalizeWebsite('nebulapay.fr'),
        'https://nebulapay.fr',
      );
      expect(CompanyValidators.normalizeWebsite('http://a.fr'), 'http://a.fr');
    });
  });
}
