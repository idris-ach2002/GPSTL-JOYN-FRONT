import '../domain/admin_user.dart';
import '../domain/user_query.dart';
import 'admin_user_repository.dart';

/// Implémentation SIMULÉE de [AdminUserRepository], en attendant l'API.
///
/// Reproduit le serveur : recherche plein texte, filtres, tri, pagination,
/// journal de modération, suppression logique (anonymisation RGPD).
class FakeAdminUserRepository implements AdminUserRepository {
  FakeAdminUserRepository({
    this.latency = const Duration(milliseconds: 600),
    List<AdminUserAccount>? seed,
  }) : _users = [...(seed ?? _seed())];

  /// Délai simulé de chaque appel (mettre `Duration.zero` dans les tests).
  final Duration latency;

  final List<AdminUserAccount> _users;
  final Set<String> _deletedIds = {};

  /// Comptes anonymisés (conservés pour l'historique).
  Set<String> get deletedIds => Set.unmodifiable(_deletedIds);

  Future<void> _network() => Future<void>.delayed(latency);

  @override
  Future<UserPage> fetchUsers(UserQuery query) async {
    await _network();
    final search = query.search.trim().toLowerCase();

    final filtered = _users.where((user) {
      if (_deletedIds.contains(user.id)) return false;
      final role = query.role.role;
      if (role != null && user.role != role) return false;
      final status = query.status.status;
      if (status != null && user.status != status) return false;
      if (search.isEmpty) return true;
      return user.firstName.toLowerCase().contains(search) ||
          user.lastName.toLowerCase().contains(search) ||
          user.fullName.toLowerCase().contains(search) ||
          user.email.toLowerCase().contains(search);
    }).toList();

    filtered.sort((a, b) {
      final comparison = query.sort.byName
          ? '${a.lastName} ${a.firstName}'.toLowerCase().compareTo(
              '${b.lastName} ${b.firstName}'.toLowerCase(),
            )
          : a.createdAt.compareTo(b.createdAt);
      return query.sort.ascending ? comparison : -comparison;
    });

    final start = (query.page - 1) * query.pageSize;
    final items = start >= filtered.length
        ? <AdminUserAccount>[]
        : filtered.skip(start).take(query.pageSize).toList();
    return UserPage(
      items: items,
      total: filtered.length,
      page: query.page,
      pageSize: query.pageSize,
    );
  }

  @override
  Future<AdminUserAccount> updateStatus(
    String id,
    AccountStatus status, {
    String? reason,
  }) async {
    await _network();
    final isSanction =
        status == AccountStatus.suspended || status == AccountStatus.banned;
    if (isSanction && (reason == null || reason.trim().isEmpty)) {
      throw const AdminUserException(
        'Un motif est obligatoire pour suspendre ou bannir.',
        statusCode: 422,
      );
    }
    final index = _indexOf(id);
    final user = _users[index];
    final entry = ModerationEntry(
      kind: switch (status) {
        AccountStatus.suspended => ModerationKind.suspended,
        AccountStatus.banned => ModerationKind.banned,
        _ => ModerationKind.reactivated,
      },
      date: DateTime.now(),
      author: 'admin@joyn.fr',
      reason: reason?.trim() ?? '',
    );
    final updated = user.copyWith(
      status: status,
      moderationHistory: [entry, ...user.moderationHistory],
    );
    _users[index] = updated;
    return updated;
  }

  @override
  Future<AdminUserAccount> updateRole(String id, AccountRole role) async {
    await _network();
    final index = _indexOf(id);
    final user = _users[index];
    final updated = user.copyWith(
      role: role,
      moderationHistory: [
        ModerationEntry(
          kind: ModerationKind.roleChanged,
          date: DateTime.now(),
          author: 'admin@joyn.fr',
          reason: '${user.role.label} → ${role.label}',
        ),
        ...user.moderationHistory,
      ],
    );
    _users[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteUser(String id) async {
    await _network();
    _indexOf(id);
    _deletedIds.add(id);
  }

  int _nextId = 1;

  /// Invitations « envoyées » (au lieu d'un vrai e-mail).
  final List<String> sentInvitations = [];

  @override
  Future<AdminUserAccount> inviteAdmin({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    await _network();
    final normalized = email.trim().toLowerCase();
    final taken = _users.any(
      (user) =>
          user.email.toLowerCase() == normalized &&
          !_deletedIds.contains(user.id),
    );
    if (taken) {
      throw const AdminUserException(
        'Un compte existe déjà avec cette adresse e-mail.',
        statusCode: 409,
      );
    }
    final user = AdminUserAccount(
      id: 'invited-${_nextId++}-${normalized.hashCode.toUnsigned(32).toRadixString(16)}',
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: normalized,
      role: AccountRole.admin,
      status: AccountStatus.pending,
      emailVerified: false,
      createdAt: DateTime.now(),
    );
    _users.add(user);
    sentInvitations.add(normalized);
    return user;
  }

  int _indexOf(String id) {
    final index = _users.indexWhere(
      (user) => user.id == id && !_deletedIds.contains(user.id),
    );
    if (index == -1) {
      throw const AdminUserException(
        'Ce compte n’existe plus.',
        statusCode: 404,
      );
    }
    return index;
  }

  /// Jeu de données de démonstration.
  static List<AdminUserAccount> _seed() {
    const firstNames = [
      'Emma',
      'Hugo',
      'Yasmine',
      'Lucas',
      'Inès',
      'Nathan',
      'Chloé',
      'Amine',
      'Léa',
      'Karim',
      'Sarah',
      'Julien',
      'Nora',
      'Théo',
      'Camille',
      'Mehdi',
    ];
    const lastNames = [
      'Arian',
      'Leroy',
      'Kacimi',
      'Martin',
      'Rahmani',
      'Moreau',
      'Petit',
      'Diallo',
      'Bernard',
      'Haddad',
      'Benali',
      'Dubois',
      'Faure',
      'Garnier',
    ];
    const companies = [
      ('cmp-1', 'Nébula Pay'),
      ('cmp-2', 'Kôr Mobility'),
      ('cmp-4', 'Talent Express'),
      ('cmp-6', 'Pixelune'),
    ];
    final now = DateTime(2026, 11, 1, 10);

    final users = <AdminUserAccount>[
      // Compte de l'administrateur de démonstration (auto-sanction bloquée).
      AdminUserAccount(
        id: 'demo-admin',
        firstName: 'Équipe',
        lastName: 'Joyn',
        email: 'admin@joyn.fr',
        role: AccountRole.admin,
        status: AccountStatus.active,
        createdAt: DateTime(2026, 1, 5),
        lastLoginAt: now,
      ),
    ];

    for (var i = 0; i < 63; i++) {
      final first = firstNames[i % firstNames.length];
      final last = lastNames[(i * 5) % lastNames.length];
      final role = i % 9 == 4
          ? AccountRole.admin
          : (i % 3 == 1 ? AccountRole.recruiter : AccountRole.candidate);
      final status = switch (i % 11) {
        3 => AccountStatus.suspended,
        7 => AccountStatus.banned,
        9 => AccountStatus.pending,
        _ => AccountStatus.active,
      };
      final company = role == AccountRole.recruiter
          ? companies[i % companies.length]
          : null;
      final created = now.subtract(Duration(days: i * 4 + 1, hours: i));
      users.add(
        AdminUserAccount(
          id: _uuid(i),
          firstName: first,
          lastName: last,
          email:
              '${first.toLowerCase()}.${last.toLowerCase()}$i@'
              '${company == null ? 'etu.exemple.fr' : 'entreprise.fr'}',
          role: role,
          status: status,
          emailVerified: status != AccountStatus.pending,
          companyId: company?.$1,
          companyName: company?.$2,
          createdAt: created,
          lastLoginAt: status == AccountStatus.pending
              ? null
              : now.subtract(Duration(days: i % 20, hours: i % 7)),
          applicationsCount: role == AccountRole.candidate ? (i * 7) % 23 : 0,
          offersCount: role == AccountRole.recruiter ? (i * 3) % 9 + 1 : 0,
          moderationHistory: switch (status) {
            AccountStatus.suspended => [
              ModerationEntry(
                kind: ModerationKind.suspended,
                date: created.add(const Duration(days: 2)),
                author: 'admin@joyn.fr',
                reason: 'Signalements répétés',
              ),
            ],
            AccountStatus.banned => [
              ModerationEntry(
                kind: ModerationKind.banned,
                date: created.add(const Duration(days: 3)),
                author: 'admin@joyn.fr',
                reason: 'Faux profil',
              ),
              ModerationEntry(
                kind: ModerationKind.suspended,
                date: created.add(const Duration(days: 1)),
                author: 'admin@joyn.fr',
                reason: 'Spam ou démarchage abusif',
              ),
            ],
            _ => const [],
          },
        ),
      );
    }
    return users;
  }

  /// UUID v4 factice et stable : « 3f1c…-…».
  static String _uuid(int index) {
    final hex = (index * 2654435761 + 0x9e3779b9)
        .toUnsigned(32)
        .toRadixString(16)
        .padLeft(8, '0');
    final tail = (index * 40503 + 0x1234).toRadixString(16).padLeft(12, '0');
    return '$hex-${hex.substring(0, 4)}-4${hex.substring(1, 4)}-a${hex.substring(5, 8)}-${tail.substring(tail.length - 12)}';
  }
}
