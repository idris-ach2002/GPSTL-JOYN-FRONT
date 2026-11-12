import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/admin_verifications/data/fake_verification_repository.dart';
import 'package:joyn_front/features/admin_verifications/data/verification_repository.dart';
import 'package:joyn_front/features/admin_verifications/domain/company_verification.dart';
import 'package:joyn_front/features/admin_verifications/presentation/controllers/admin_verifications_controller.dart';

class _ForbiddenRepository extends FakeVerificationRepository {
  _ForbiddenRepository() : super(latency: Duration.zero);

  @override
  Future<List<CompanyVerification>> fetchVerifications({
    required VerificationFilter filter,
    String search = '',
  }) async =>
      throw const VerificationException('Accès refusé.', statusCode: 403);
}

Future<void> _flush() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  late AdminVerificationsController controller;

  setUp(() async {
    controller = AdminVerificationsController(
      FakeVerificationRepository(latency: Duration.zero),
      searchDebounce: Duration.zero,
    );
    await controller.load();
  });

  tearDown(() => controller.dispose());

  test('la première demande est sélectionnée', () {
    expect(controller.status, VerificationsStatus.ready);
    expect(controller.selected?.id, controller.items.first.id);
  });

  test('valider manuellement sort la demande de la file', () async {
    final item = controller.items.firstWhere((i) => i.id == 'ver-3');
    final result = await controller.approve(item, note: 'Kbis reçu');
    expect(result.succeeded, isTrue);
    expect(result.message, contains('ses offres deviennent visibles'));
    expect(controller.items.any((i) => i.id == 'ver-3'), isFalse);
    // La sélection passe à la demande suivante.
    expect(controller.selected, isNotNull);
  });

  test('relancer une demande dont l’API était indisponible', () async {
    final item = controller.items.firstWhere((i) => i.id == 'ver-6');
    final result = await controller.retry(item);
    expect(result.message, contains('vérifiée automatiquement'));
    expect(controller.items.any((i) => i.id == 'ver-6'), isFalse);
  });

  test('demander un justificatif', () async {
    final item = controller.items.firstWhere((i) => i.id == 'ver-5');
    final result = await controller.requestDocument(
      item,
      'Extrait Kbis de moins de 3 mois',
    );
    expect(result.message, contains(item.recruiterEmail!));

    controller.setFilter(VerificationFilter.documentRequested);
    await _flush();
    expect(controller.items.map((i) => i.id), contains('ver-5'));
  });

  test('recherche', () async {
    controller.setSearch('maison');
    await _flush();
    expect(controller.items.single.companyName, 'Maison Grenat');
  });

  test('une réponse 403 affiche l’accès refusé', () async {
    final forbidden = AdminVerificationsController(_ForbiddenRepository());
    await forbidden.load();
    expect(forbidden.status, VerificationsStatus.forbidden);
    forbidden.dispose();
  });
}
