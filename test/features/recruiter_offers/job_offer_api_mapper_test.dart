import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/recruiter_offers/data/job_offer_api_mapper.dart';
import 'package:joyn_front/features/recruiter_offers/domain/job_offer.dart';
import 'package:joyn_front/features/recruiter_offers/domain/job_offer_draft.dart';

void main() {
  test('le payload de création reprend les noms JSON du backend Spring', () {
    const draft = JobOfferDraft(
      companyId: 42,
      title: 'Développeur·se Full-Stack en alternance',
      contractType: ContractType.apprenticeship,
      location: 'Paris 9e',
      remoteMode: RemoteMode.hybrid,
      experienceLevel: ExperienceLevel.junior,
      description: 'Construire le nouveau tableau de bord.',
      salaryMin: 1450,
      salaryMax: 1600,
      currency: 'EUR',
      salaryPeriod: SalaryPeriod.month,
      skills: ['React', 'TypeScript', 'PostgreSQL'],
      rhythmType: '3 sem / 1 sem',
      startDate: DateTime(2027, 9, 1),
      durationMonths: 24,
      degreeLevelRequired: 'BAC_5',
    );

    final json = JobOfferApiMapper.toCreateJson(
      draft,
      JobOfferStatus.published,
    );

    expect(json['contract_type'], 'APPRENTICESHIP');
    expect(json['remote_policy'], 'HYBRID');
    expect(json['experience_level'], 'JUNIOR');
    expect(json['salary_period'], 'MONTH');
    expect(json['start_date'], '2027-09-01');
    expect(json['degree_level_required'], 'BAC_5');
    expect(json['status'], 'PUBLISHED');
    expect(json.containsKey('company_id'), isFalse);
  });
}
