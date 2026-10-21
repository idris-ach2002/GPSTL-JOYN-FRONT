import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/registration/domain/email_rules.dart';

void main() {
  group('EmailRules.isValid', () {
    test('accepte une adresse classique', () {
      expect(EmailRules.isValid('yasmine.kacimi@gmail.com'), isTrue);
    });

    test('refuse une adresse incomplète', () {
      expect(EmailRules.isValid('yasmine@'), isFalse);
      expect(EmailRules.isValid('yasmine.gmail.com'), isFalse);
      expect(EmailRules.isValid('yasmine@gmail.c'), isFalse);
    });
  });

  group('EmailRules.looksLikeStudentEmail', () {
    test('reconnaît les domaines universitaires', () {
      expect(
        EmailRules.looksLikeStudentEmail('feriel@etu.sorbonne-universite.fr'),
        isTrue,
      );
      expect(
        EmailRules.looksLikeStudentEmail('yasmine.kacimi@etu.u-paris.fr'),
        isTrue,
      );
      expect(EmailRules.looksLikeStudentEmail('hugo@insa-lyon.fr'), isTrue);
    });

    test('ne reconnaît pas les messageries personnelles', () {
      expect(EmailRules.looksLikeStudentEmail('hugo@gmail.com'), isFalse);
      expect(EmailRules.looksLikeStudentEmail('hugo@outlook.fr'), isFalse);
    });
  });
}
