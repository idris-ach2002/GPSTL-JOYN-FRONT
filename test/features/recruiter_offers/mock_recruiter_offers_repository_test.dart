import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/recruiter_offers/data/mock_recruiter_offers_repository.dart';
import 'package:joyn_front/features/recruiter_offers/domain/job_offer.dart';
import 'package:joyn_front/features/recruiter_offers/domain/job_offer_draft.dart';
import 'package:joyn_front/features/recruiter_offers/domain/recruiter_company.dart';

void main() {
  group('MockRecruiterOffersRepository', () {
    late MockRecruiterOffersRepository repository;

    setUp(() {
      repository = MockRecruiterOffersRepository(latency: Duration.zero);
    });

    test('expose les entreprises disponibles dans la base', () async {
      final companies = await repository.fetchCompanies();
      expect(
        companies.map((company) => company.name),
        containsAll(['Joyn', 'Orbix', 'Metria', 'Helios']),
      );

      final found = await repository.findCompanyBySiret('732 829 320 00074');
      expect(found?.name, 'Joyn');
    });

    test('crée une entreprise absente puis la rend disponible', () async {
      final company = await repository.createCompany(
        const RecruiterCompanyDraft(
          name: 'Nova Tech',
          sector: 'SaaS B2B',
          sizeRange: '11 – 49',
          city: 'Paris, France',
          siret: '12345678901234',
        ),
      );

      expect(company.name, 'Nova Tech');
      expect((await repository.fetchCompanies()).last.name, 'Nova Tech');
      expect(
        (await repository.findCompanyBySiret('12345678901234'))?.id,
        company.id,
      );
    });

    test('crée, met à jour puis clôture une offre', () async {
      const draft = JobOfferDraft(
        companyId: 1,
        title: 'Développeur Flutter',
        contractType: ContractType.cdi,
        location: 'Paris',
        remoteMode: RemoteMode.hybrid,
        experienceLevel: ExperienceLevel.mid,
        description: 'Construire l’application JOYN.',
        skills: ['Flutter', 'Dart'],
      );

      final created = await repository.createOffer(
        draft,
        JobOfferStatus.published,
      );
      expect(created.status, JobOfferStatus.published);
      expect(created.publishedAt, isNotNull);

      final updated = await repository.updateOffer(
        created.id,
        const JobOfferDraft(
          companyId: 1,
          title: 'Lead Flutter',
          contractType: ContractType.cdi,
          location: 'Paris',
          remoteMode: RemoteMode.hybrid,
          experienceLevel: ExperienceLevel.senior,
          description: 'Faire évoluer l’application JOYN.',
          skills: ['Flutter', 'Dart', 'CI/CD'],
        ),
      );
      expect(updated.title, 'Lead Flutter');

      await repository.closeOffer(created.id, reason: 'Poste pourvu');
      expect(
        (await repository.fetchOffer(created.id))?.status,
        JobOfferStatus.closed,
      );
    });
  });
}
