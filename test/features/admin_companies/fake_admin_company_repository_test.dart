import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/admin_companies/data/admin_company_repository.dart';
import 'package:joyn_front/features/admin_companies/data/fake_admin_company_repository.dart';
import 'package:joyn_front/features/admin_companies/domain/admin_company.dart';
import 'package:joyn_front/features/admin_companies/domain/company_validators.dart';

void main() {
  late FakeAdminCompanyRepository repository;

  setUp(() => repository = FakeAdminCompanyRepository(latency: Duration.zero));

  test('pagination côté serveur : 20 par page', () async {
    final first = await repository.fetchCompanies(const CompanyQuery());
    expect(first.items, hasLength(20));
    expect(first.total, 45);
    expect(first.totalPages, 3);

    final last = await repository.fetchCompanies(const CompanyQuery(page: 3));
    expect(last.items, hasLength(5));
    expect(last.firstIndex, 41);
    expect(last.lastIndex, 45);
  });

  test('tous les SIRET de démonstration sont valides', () async {
    final page = await repository.fetchCompanies(
      const CompanyQuery(pageSize: 100),
    );
    for (final company in page.items) {
      expect(CompanyValidators.siretError(company.siret), isNull);
    }
  });

  test('recherche sur le nom et sur le SIRET', () async {
    final byName = await repository.fetchCompanies(
      const CompanyQuery(search: 'nébula', pageSize: 100),
    );
    expect(byName.items, isNotEmpty);
    expect(byName.items.every((c) => c.name.contains('Nébula')), isTrue);

    final target = byName.items.first;
    final bySiret = await repository.fetchCompanies(
      CompanyQuery(search: CompanyValidators.formatSiret(target.siret)),
    );
    expect(bySiret.items.single.id, target.id);
  });

  test('filtres de statut et de secteur', () async {
    final pending = await repository.fetchCompanies(
      const CompanyQuery(status: CompanyStatusFilter.pending, pageSize: 100),
    );
    expect(
      pending.items.every((c) => c.status == CompanyStatus.pending),
      isTrue,
    );

    final moderated = await repository.fetchCompanies(
      const CompanyQuery(
        status: CompanyStatusFilter.rejectedOrSuspended,
        pageSize: 100,
      ),
    );
    expect(
      moderated.items.every(
        (c) =>
            c.status == CompanyStatus.rejected ||
            c.status == CompanyStatus.suspended,
      ),
      isTrue,
    );

    final banks = await repository.fetchCompanies(
      const CompanyQuery(sector: 'Banque', pageSize: 100),
    );
    expect(banks.items.every((c) => c.sector == 'Banque'), isTrue);
  });

  test('tri par nom et par date', () async {
    final byName = await repository.fetchCompanies(
      const CompanyQuery(sort: CompanySort.nameAsc, pageSize: 100),
    );
    final names = byName.items.map((c) => c.name.toLowerCase()).toList();
    expect(names, [...names]..sort());

    final newest = await repository.fetchCompanies(const CompanyQuery());
    final oldest = await repository.fetchCompanies(
      const CompanyQuery(sort: CompanySort.oldest),
    );
    expect(
      newest.items.first.createdAt.isAfter(oldest.items.first.createdAt),
      isTrue,
    );
  });

  test('rejeter exige un motif et prévient le recruteur', () async {
    final company = (await repository.fetchCompanies(
      const CompanyQuery(status: CompanyStatusFilter.pending),
    )).items.first;

    expect(
      () => repository.updateStatus(company.id, CompanyStatus.rejected),
      throwsA(isA<AdminCompanyException>()),
    );

    await repository.updateStatus(
      company.id,
      CompanyStatus.rejected,
      reason: 'Suspicion de fraude',
    );
    expect(repository.sentNotifications.single.reason, 'Suspicion de fraude');
    expect(
      repository.sentNotifications.single.recipient,
      company.recruiterEmail,
    );
  });

  test('suppression logique : masquée mais conservée', () async {
    final company = (await repository.fetchCompanies(const CompanyQuery()))
        .items
        .first;
    await repository.deleteCompany(company.id);

    final page = await repository.fetchCompanies(
      const CompanyQuery(pageSize: 100),
    );
    expect(page.total, 44);
    expect(page.items.any((c) => c.id == company.id), isFalse);
    expect(repository.deletedIds, contains(company.id));
  });

  test('création : un SIRET déjà utilisé est refusé', () async {
    final existing = (await repository.fetchCompanies(const CompanyQuery()))
        .items
        .first;
    expect(
      () => repository.createCompany(
        CompanyDraft(
          name: 'Doublon',
          siret: existing.siret,
          sector: 'Autre',
          city: 'Paris',
        ),
      ),
      throwsA(
        isA<AdminCompanyException>().having((e) => e.statusCode, 'code', 409),
      ),
    );
  });
}
