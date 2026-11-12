import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/admin_companies/data/admin_company_repository.dart';
import 'package:joyn_front/features/admin_companies/data/fake_admin_company_repository.dart';
import 'package:joyn_front/features/admin_companies/domain/admin_company.dart';
import 'package:joyn_front/features/admin_companies/presentation/controllers/admin_companies_controller.dart';

class _ForbiddenRepository extends FakeAdminCompanyRepository {
  _ForbiddenRepository() : super(latency: Duration.zero);

  @override
  Future<CompanyPage> fetchCompanies(CompanyQuery query) async =>
      throw const AdminCompanyException('Accès refusé.', statusCode: 403);
}

void main() {
  late FakeAdminCompanyRepository repository;
  late AdminCompaniesController controller;

  setUp(() async {
    repository = FakeAdminCompanyRepository(latency: Duration.zero);
    controller = AdminCompaniesController(
      repository,
      searchDebounce: Duration.zero,
    );
    await controller.load();
  });

  tearDown(() => controller.dispose());

  test('premier chargement', () {
    expect(controller.status, AdminCompaniesStatus.ready);
    expect(controller.companies, hasLength(20));
    expect(controller.page?.total, 45);
  });

  test('changer de filtre revient à la page 1', () async {
    controller.goToPage(2);
    await Future<void>.delayed(Duration.zero);
    expect(controller.query.page, 2);

    controller.setStatusFilter(CompanyStatusFilter.pending);
    await Future<void>.delayed(Duration.zero);
    expect(controller.query.page, 1);
    expect(
      controller.companies.every((c) => c.status == CompanyStatus.pending),
      isTrue,
    );
    expect(controller.hasActiveFilters, isTrue);
  });

  test('la recherche est lancée après le délai de saisie', () async {
    controller.setSearch('Pixelune');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(controller.query.search, 'Pixelune');
    expect(
      controller.companies.every((c) => c.name.contains('Pixelune')),
      isTrue,
    );
  });

  test('valider : message de confirmation et statut mis à jour', () async {
    final pending = controller.companies.firstWhere(
      (c) => c.status == CompanyStatus.pending,
    );
    final result = await controller.approve(pending);
    expect(result.succeeded, isTrue);
    expect(result.message, contains('ses offres sont maintenant visibles'));

    final refreshed = controller.companies.firstWhere(
      (c) => c.id == pending.id,
    );
    expect(refreshed.status, CompanyStatus.approved);
  });

  test('suspendre avec motif : le recruteur est prévenu', () async {
    final approved = controller.companies.firstWhere(
      (c) => c.status == CompanyStatus.approved,
    );
    final result = await controller.suspend(approved, 'Entreprise inactive');
    expect(result.succeeded, isTrue);
    expect(result.message, contains('prévenu·e par e-mail'));
    expect(repository.sentNotifications.single.status, CompanyStatus.suspended);
  });

  test('créer, modifier puis supprimer', () async {
    const draft = CompanyDraft(
      name: 'Zeta Conseil',
      siret: '73282932000074',
      sector: 'Conseil',
      city: 'Rennes',
      initialStatus: CompanyStatus.approved,
    );
    expect((await controller.create(draft)).succeeded, isTrue);

    controller.setSearch('Zeta');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final created = controller.companies.single;
    expect(created.status, CompanyStatus.approved);
    expect(created.recruiterName, isNull);

    final updated = await controller.update(
      created.id,
      const CompanyDraft(
        name: 'Zeta Conseil SAS',
        siret: '73282932000074',
        sector: 'Conseil',
        city: 'Rennes',
      ),
    );
    expect(updated.succeeded, isTrue);
    expect(controller.companies.single.name, 'Zeta Conseil SAS');

    final deleted = await controller.delete(controller.companies.single);
    expect(deleted.message, contains('historique des candidatures'));
    expect(controller.companies, isEmpty);
  });

  test('un SIRET en double renvoie un échec affichable', () async {
    final existing = controller.companies.first;
    final result = await controller.create(
      CompanyDraft(
        name: 'Doublon',
        siret: existing.siret,
        sector: 'Autre',
        city: 'Paris',
      ),
    );
    expect(result.succeeded, isFalse);
    expect(result.message, contains('déjà enregistrée'));
  });

  test('une réponse 403 affiche l’accès refusé', () async {
    final forbidden = AdminCompaniesController(_ForbiddenRepository());
    await forbidden.load();
    expect(forbidden.status, AdminCompaniesStatus.forbidden);
    forbidden.dispose();
  });
}
