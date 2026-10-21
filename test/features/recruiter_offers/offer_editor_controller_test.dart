import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/recruiter_offers/data/mock_recruiter_offers_repository.dart';
import 'package:joyn_front/features/recruiter_offers/domain/job_offer.dart';
import 'package:joyn_front/features/recruiter_offers/domain/recruiter_company.dart';
import 'package:joyn_front/features/recruiter_offers/presentation/controllers/offer_editor_controller.dart';

void main() {
  group('OfferEditorController', () {
    late MockRecruiterOffersRepository repository;
    late OfferEditorController controller;

    setUp(() async {
      repository = MockRecruiterOffersRepository(latency: Duration.zero);
      controller = OfferEditorController(repository);
      await controller.load();
    });

    test('sélectionne par défaut la première entreprise de la base', () {
      expect(controller.companies, isNotEmpty);
      expect(controller.selectedCompany?.name, 'Joyn');
    });

    test('refuse une fourchette de salaire inversée', () {
      controller
        ..updateSalaryMin('2000')
        ..updateSalaryMax('1500');

      expect(controller.validate(), isFalse);
      expect(controller.errors['salary'], contains('maximum'));
    });

    test('impose au moins une compétence', () {
      for (final skill in [...controller.skills]) {
        controller.removeSkill(skill);
      }

      expect(controller.validate(), isFalse);
      expect(controller.errors['skills'], isNotNull);
    });

    test('évite les doublons de compétences sans tenir compte de la casse', () {
      expect(controller.addSkill('React'), isFalse);
      expect(controller.skills.where((skill) => skill.toLowerCase() == 'react'), hasLength(1));
    });

    test('crée une entreprise manuelle et la sélectionne', () async {
      final company = await controller.createCompany(
        const RecruiterCompanyDraft(
          name: 'Nova Tech',
          sector: 'SaaS B2B',
          sizeRange: '11 – 49',
          city: 'Paris',
        ),
      );

      expect(company, isNotNull);
      expect(controller.selectedCompany?.name, 'Nova Tech');
      expect(controller.companies.last.name, 'Nova Tech');
    });

    test('publie une offre valide avec le mock', () async {
      final saved = await controller.submit(JobOfferStatus.published);
      expect(saved, isNotNull);
      expect(saved?.status, JobOfferStatus.published);
      expect((await repository.fetchOffers()).first.id, saved?.id);
    });
  });
}
