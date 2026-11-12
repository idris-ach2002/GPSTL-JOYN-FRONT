import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/admin_users/data/admin_user_repository.dart';
import 'package:joyn_front/features/admin_users/data/fake_admin_user_repository.dart';
import 'package:joyn_front/features/admin_users/domain/admin_user.dart';
import 'package:joyn_front/features/admin_users/domain/user_query.dart';

void main() {
  late FakeAdminUserRepository repository;

  setUp(() => repository = FakeAdminUserRepository(latency: Duration.zero));

  test('pagination : 20 par page sur 64 comptes', () async {
    final first = await repository.fetchUsers(const UserQuery());
    expect(first.items, hasLength(20));
    expect(first.total, 64);
    expect(first.totalPages, 4);
  });

  test('recherche plein texte sur prénom, nom et e-mail', () async {
    final byName = await repository.fetchUsers(
      const UserQuery(search: 'emma', pageSize: 100),
    );
    expect(byName.items, isNotEmpty);
    expect(
      byName.items.every((u) => u.fullName.toLowerCase().contains('emma')),
      isTrue,
    );

    final byEmail = await repository.fetchUsers(
      const UserQuery(search: 'admin@joyn.fr'),
    );
    expect(byEmail.items.single.id, 'demo-admin');
  });

  test('filtres de rôle et de statut', () async {
    final recruiters = await repository.fetchUsers(
      const UserQuery(role: UserRoleFilter.recruiter, pageSize: 100),
    );
    expect(
      recruiters.items.every((u) => u.role == AccountRole.recruiter),
      isTrue,
    );
    expect(recruiters.items.every((u) => u.companyName != null), isTrue);

    final banned = await repository.fetchUsers(
      const UserQuery(status: UserStatusFilter.banned, pageSize: 100),
    );
    expect(banned.items.every((u) => u.status == AccountStatus.banned), isTrue);
    expect(banned.items.every((u) => u.moderationHistory.isNotEmpty), isTrue);
  });

  test('tri par nom', () async {
    final page = await repository.fetchUsers(
      const UserQuery(sort: UserSort.nameAsc, pageSize: 100),
    );
    final names = page.items
        .map((u) => '${u.lastName} ${u.firstName}'.toLowerCase())
        .toList();
    expect(names, [...names]..sort());
  });

  test('une sanction exige un motif et alimente le journal', () async {
    final user = (await repository.fetchUsers(
      const UserQuery(status: UserStatusFilter.active),
    )).items.firstWhere((u) => u.id != 'demo-admin');

    expect(
      () => repository.updateStatus(user.id, AccountStatus.suspended),
      throwsA(isA<AdminUserException>()),
    );

    final suspended = await repository.updateStatus(
      user.id,
      AccountStatus.suspended,
      reason: 'Faux profil',
    );
    expect(suspended.status, AccountStatus.suspended);
    expect(suspended.moderationHistory.first.kind, ModerationKind.suspended);
    expect(suspended.moderationHistory.first.reason, 'Faux profil');
  });

  test('changement de rôle tracé dans le journal', () async {
    final candidate = (await repository.fetchUsers(
      const UserQuery(role: UserRoleFilter.candidate),
    )).items.first;
    final updated = await repository.updateRole(
      candidate.id,
      AccountRole.recruiter,
    );
    expect(updated.role, AccountRole.recruiter);
    expect(updated.moderationHistory.first.kind, ModerationKind.roleChanged);
  });

  test('invitation d’un admin : doublon d’e-mail refusé', () async {
    final invited = await repository.inviteAdmin(
      firstName: 'Nina',
      lastName: 'Morel',
      email: 'nina@joyn.fr',
    );
    expect(invited.role, AccountRole.admin);
    expect(invited.status, AccountStatus.pending);
    expect(
      () => repository.inviteAdmin(
        firstName: 'Autre',
        lastName: 'Nina',
        email: 'NINA@joyn.fr',
      ),
      throwsA(
        isA<AdminUserException>().having((e) => e.statusCode, 'code', 409),
      ),
    );
  });

  test('suppression logique : compte masqué mais conservé', () async {
    final user = (await repository.fetchUsers(const UserQuery())).items.last;
    await repository.deleteUser(user.id);
    final page = await repository.fetchUsers(const UserQuery(pageSize: 100));
    expect(page.total, 63);
    expect(page.items.any((u) => u.id == user.id), isFalse);
    expect(repository.deletedIds, contains(user.id));
  });
}
