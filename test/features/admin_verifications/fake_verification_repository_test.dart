import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/admin_verifications/data/fake_verification_repository.dart';
import 'package:joyn_front/features/admin_verifications/data/verification_repository.dart';
import 'package:joyn_front/features/admin_verifications/domain/company_verification.dart';

void main() {
  late FakeVerificationRepository repository;

  setUp(() => repository = FakeVerificationRepository(latency: Duration.zero));

  test('la file « À traiter » ne contient que des échecs, du plus ancien au plus récent', () async {
    final items = await repository.fetchVerifications(
      filter: VerificationFilter.toReview,
    );
    expect(items, hasLength(6));
    expect(items.every((i) => i.status == VerificationStatus.toReview), isTrue);
    expect(items.first.submittedAt.isBefore(items.last.submittedAt), isTrue);
  });

  test('recherche par nom et par SIRET', () async {
    final byName = await repository.fetchVerifications(
      filter: VerificationFilter.all,
      search: 'vertigo',
    );
    expect(byName.single.companyName, 'Vertigo Labs');

    final bySiret = await repository.fetchVerifications(
      filter: VerificationFilter.all,
      search: '844 555 666',
    );
    expect(bySiret.single.companyName, 'Vertigo Labs');
  });

  test('relancer réussit quand l’API était indisponible', () async {
    final updated = await repository.retryAutomatic('ver-1');
    expect(updated.status, VerificationStatus.verifiedAuto);
    expect(updated.issue, VerificationIssue.none);
    expect(updated.apiMessage, isNull);
    expect(
      updated.checks.every((c) => c.outcome == CheckOutcome.passed),
      isTrue,
    );
  });

  test('relancer ne change rien pour un vrai problème', () async {
    final updated = await repository.retryAutomatic('ver-2');
    expect(updated.status, VerificationStatus.toReview);
    expect(updated.history.first.label, 'Relance : même résultat');
  });

  test('décisions manuelles', () async {
    final approved = await repository.decide(
      'ver-3',
      VerificationDecision.approve,
    );
    expect(approved.status, VerificationStatus.verifiedManual);

    expect(
      () => repository.decide('ver-4', VerificationDecision.refuse),
      throwsA(isA<VerificationException>()),
    );
    final refused = await repository.decide(
      'ver-4',
      VerificationDecision.refuse,
      note: 'Établissement fermé',
    );
    expect(refused.status, VerificationStatus.refused);
    expect(refused.history.first.note, 'Établissement fermé');
  });
}
