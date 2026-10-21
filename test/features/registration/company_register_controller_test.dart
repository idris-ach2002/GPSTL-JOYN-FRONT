import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/registration/data/mock_registration_repository.dart';
import 'package:joyn_front/features/registration/presentation/controllers/company_register_controller.dart';

CompanyRegisterController _controller() {
  return CompanyRegisterController(
    repository: MockRegistrationRepository(latency: Duration.zero),
  );
}

void main() {
  group('CompanyRegisterController', () {
    test('un SIRET incomplet affiche une erreur après la recherche', () async {
      final form = _controller()..updateSiret('123 456');
      expect(form.visibleErrorFor(CompanyRegisterField.siret), isNull);

      await form.searchCompany();
      expect(
        form.visibleErrorFor(CompanyRegisterField.siret),
        'Un numéro SIRET compte 14 chiffres.',
      );
    });

    test('le SIRET de démo retrouve Alex Dupont et pré-remplit', () async {
      final form = _controller()..updateSiret('12345678900012');
      expect(form.siret, '123 456 789 00012');

      await form.searchCompany();
      expect(form.companyFound, isTrue);
      expect(form.companyName, 'Alex Dupont');
      expect(form.sector, 'Fintech');
      expect(form.sizeRange, '50 – 249');
      expect(form.errorFor(CompanyRegisterField.siret), isNull);
    });

    test('un SIRET inconnu est signalé', () async {
      final form = _controller()..updateSiret('99999999999999');
      await form.searchCompany();
      expect(form.lookupStatus, SiretLookupStatus.notFound);
      expect(
        form.visibleErrorFor(CompanyRegisterField.siret),
        contains('Aucune entreprise'),
      );
    });

    test('modifier le SIRET annule le résultat', () async {
      final form = _controller()..updateSiret('12345678900012');
      await form.searchCompany();
      form.updateSiret('1234567890001');
      expect(form.companyFound, isFalse);
      expect(form.lookupStatus, SiretLookupStatus.idle);
    });

    test('indications sur l’e-mail', () async {
      final form = _controller()..updateSiret('12345678900012');
      await form.searchCompany();

      form.updateEmail('camille.roux@nebulapay.fr');
      expect(form.emailHint, CompanyEmailHint.matchesCompany);

      form.updateEmail('camille.roux@gmail.com');
      expect(form.emailHint, CompanyEmailHint.personal);

      form.updateEmail('camille@autre-societe.fr');
      expect(form.emailHint, CompanyEmailHint.advice);
    });

    test('le téléphone est facultatif mais doit être valide', () {
      final form = _controller();
      expect(form.errorFor(CompanyRegisterField.phone), isNull);

      form.updatePhone('06 12 34');
      expect(form.errorFor(CompanyRegisterField.phone), isNotNull);

      form.updatePhone('06 12 34 56 78');
      expect(form.errorFor(CompanyRegisterField.phone), isNull);

      form.updatePhone('+33 6 12 34 56 78');
      expect(form.errorFor(CompanyRegisterField.phone), isNull);
    });

    test('un formulaire complet crée l’espace', () async {
      final form = _controller()
        ..updateSiret('12345678900012')
        ..updateFirstName('Camille')
        ..updateLastName('Roux')
        ..setJobTitle('Responsable RH')
        ..updateEmail('camille.roux.test@nebulapay.fr')
        ..updatePassword('Joyn2026!')
        ..setAcceptedTerms(true);
      await form.searchCompany();

      expect(form.isValid, isTrue);
      expect(await form.submit(), isTrue);
      expect(form.recruiterName, 'Camille R.');
    });

    test('un envoi vide compte toutes les erreurs', () async {
      final form = _controller();
      expect(await form.submit(), isFalse);
      // SIRET, prénom, nom, fonction, e-mail, mot de passe, conditions.
      expect(form.errorCount, 7);
      expect(form.showErrorSummary, isTrue);
    });
  });
}
