import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/admin_users/data/admin_user_repository.dart';
import 'package:joyn_front/features/admin_users/data/fake_admin_user_repository.dart';
import 'package:joyn_front/features/admin_users/domain/admin_user.dart';
import 'package:joyn_front/features/admin_users/domain/user_query.dart';
import 'package:joyn_front/features/admin_users/presentation/controllers/admin_users_controller.dart';

class _ForbiddenRepository extends FakeAdminUserRepository {
  _ForbiddenRepository() : super(latency: Duration.zero);

  @override
  Future<UserPage> fetchUsers(UserQuery query) async =>
      throw const AdminUserException('Accès refusé.', statusCode: 403);
}

Future<void> _flush() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  late FakeAdminUserRepository repository;
  late AdminUsersController controller;
  late List<UserQuery> urlWrites;

  setUp(() async {
    repository = FakeAdminUserRepository(latency: Duration.zero);
    controller = AdminUsersController(
      repository,
      currentUserId: 'demo-admin',
      searchDebounce: Duration.zero,
    );
    urlWrites = [];
    controller
      ..onQueryChanged = urlWrites.add
      ..syncWithUrl(const UserQuery());
    await _flush();
  });

  tearDown(() => controller.dispose());

  test('chargement depuis l’URL', () async {
    controller.syncWithUrl(
      const UserQuery(role: UserRoleFilter.candidate, page: 2),
    );
    await _flush();
    expect(controller.query.role, UserRoleFilter.candidate);
    expect(controller.query.page, 2);
    expect(
      controller.users.every((u) => u.role == AccountRole.candidate),
      isTrue,
    );
    // Appliquer l'URL ne la réécrit pas.
    expect(urlWrites, isEmpty);
  });

  test('changer un filtre revient page 1 et met l’URL à jour', () async {
    controller.goToPage(2);
    await _flush();
    controller.setStatusFilter(UserStatusFilter.suspended);
    await _flush();

    expect(controller.query.page, 1);
    expect(urlWrites.last.status, UserStatusFilter.suspended);
    expect(urlWrites.last.toQueryParameters(), {'status': 'suspended'});
  });

  test('recherche après le délai, puis réinitialisation', () async {
    controller.setSearch('emma');
    await _flush();
    expect(controller.query.search, 'emma');
    expect(controller.query.hasFilters, isTrue);

    controller.resetFilters();
    await _flush();
    expect(controller.query.hasFilters, isFalse);
    expect(urlWrites.last.toQueryParameters(), isEmpty);
  });

  test('une recherche sans résultat donne une liste vide', () async {
    controller.setSearch('zzzzzz');
    await _flush();
    expect(controller.status, AdminUsersStatus.ready);
    expect(controller.users, isEmpty);
  });

  test('auto-sanction bloquée', () async {
    final me = (await repository.fetchUsers(
      const UserQuery(search: 'admin@joyn.fr'),
    )).items.single;
    expect(controller.isSelf(me), isTrue);

    final suspend = await controller.suspend(me, 'Test');
    expect(suspend.succeeded, isFalse);
    expect(suspend.message, contains('votre propre compte'));

    final demote = await controller.changeRole(me, AccountRole.candidate);
    expect(demote.succeeded, isFalse);

    final delete = await controller.delete(me);
    expect(delete.succeeded, isFalse);
  });

  test('suspendre puis réactiver', () async {
    final user = controller.users.firstWhere(
      (u) => u.status == AccountStatus.active && !controller.isSelf(u),
    );
    final suspended = await controller.suspend(user, 'Signalements répétés');
    expect(suspended.succeeded, isTrue);
    expect(controller.findById(user.id)?.status, AccountStatus.suspended);

    final reactivated = await controller.reactivate(
      controller.findById(user.id)!,
    );
    expect(reactivated.succeeded, isTrue);
    expect(controller.findById(user.id)?.status, AccountStatus.active);
  });

  test('promouvoir en admin', () async {
    final candidate = controller.users.firstWhere(
      (u) => u.role == AccountRole.candidate,
    );
    final result = await controller.changeRole(candidate, AccountRole.admin);
    expect(result.succeeded, isTrue);
    expect(result.message, contains('admin'));
  });

  test('inviter un admin : compte en attente et notification', () async {
    final result = await controller.inviteAdmin(
      firstName: 'Nina',
      lastName: 'Morel',
      email: 'Nina.Morel@joyn.fr',
    );
    expect(result.succeeded, isTrue);
    expect(result.message, contains('nina.morel@joyn.fr'));
    expect(repository.sentInvitations, ['nina.morel@joyn.fr']);

    controller.setSearch('nina.morel');
    await _flush();
    final invited = controller.users.single;
    expect(invited.role, AccountRole.admin);
    expect(invited.status, AccountStatus.pending);
    expect(invited.emailVerified, isFalse);
  });

  test('inviter une adresse déjà utilisée échoue proprement', () async {
    final result = await controller.inviteAdmin(
      firstName: 'Équipe',
      lastName: 'Joyn',
      email: 'admin@joyn.fr',
    );
    expect(result.succeeded, isFalse);
    expect(result.message, contains('existe déjà'));
    expect(controller.isInviting, isFalse);
  });

  test('une réponse 403 affiche l’accès refusé', () async {
    final forbidden = AdminUsersController(
      _ForbiddenRepository(),
      currentUserId: null,
    );
    await forbidden.load();
    expect(forbidden.status, AdminUsersStatus.forbidden);
    forbidden.dispose();
  });
}
