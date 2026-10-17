import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/registration/data/mock_registration_repository.dart';
import 'package:joyn_front/features/registration/presentation/controllers/student_register_controller.dart';

StudentRegisterController _controller() {
  return StudentRegisterController(
    repository: MockRegistrationRepository(latency: Duration.zero),
  );
}

void _fillValidForm(StudentRegisterController form, {required String email}) {
  form
    ..updateFirstName('Yasmine')
    ..updateLastName('Kacimi')
    ..updateEmail(email)
    ..updatePassword('Joyn2026!')
    ..setAcceptedTerms(true);
}

void main() {
  group('StudentRegisterController', () {
    test('aucune erreur visible avant la première tentative', () {
      final form = _controller();
      expect(form.errorCount, 5);
      for (final field in StudentRegisterField.values) {
        expect(form.visibleErrorFor(field), isNull);
      }
      expect(form.showErrorSummary, isFalse);
    });

    test('une tentative sur un formulaire vide affiche les 5 erreurs', () async {
      final form = _controller();
      final created = await form.submit();

      expect(created, isFalse);
      expect(form.showErrorSummary, isTrue);
      expect(
        form.errorSummary,
        'Il reste 5 points à corriger avant de créer ton compte.',
      );
      expect(
        form.visibleErrorFor(StudentRegisterField.firstName),
        'Indique ton prénom.',
      );
    });

    test('un formulaire complet crée le compte', () async {
      final form = _controller();
      _fillValidForm(form, email: 'yasmine.k1@etu.u-paris.fr');

      expect(form.isValid, isTrue);
      expect(await form.submit(), isTrue);
      expect(form.isSubmitting, isFalse);
      expect(form.submitError, isNull);
    });

    test('une adresse déjà utilisée renvoie un message', () async {
      final form = _controller();
      _fillValidForm(form, email: 'deja.inscrite@etu.sorbonne-universite.fr');

      expect(await form.submit(), isFalse);
      expect(form.submitError, contains('existe déjà'));
    });

    test('aperçu : initiales et nom affiché', () {
      final form = _controller();
      expect(form.initials, '?');
      expect(form.displayName, 'Ton prénom');

      form
        ..updateFirstName('yasmine')
        ..updateLastName('kacimi');
      expect(form.initials, 'YK');
      expect(form.displayName, 'yasmine K.');
    });
  });
}
