import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/registration/domain/siret.dart';

void main() {
  group('Siret', () {
    test('formate en 3-3-3-5 et ignore tout sauf les chiffres', () {
      expect(Siret.format('12345678900012'), '123 456 789 00012');
      expect(Siret.format('123-456 78a9'), '123 456 789');
      expect(Siret.format('1234'), '123 4');
      expect(Siret.format(''), '');
    });

    test('coupe au-delà de 14 chiffres', () {
      expect(Siret.digitsOf('123456789000123456'), '12345678900012');
    });

    test('vérifie la longueur', () {
      expect(Siret.hasValidLength('123 456 789 00012'), isTrue);
      expect(Siret.hasValidLength('123 456 789'), isFalse);
    });
  });
}
