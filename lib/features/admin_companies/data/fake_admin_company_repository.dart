import '../domain/admin_company.dart';
import 'admin_company_repository.dart';

/// Notification envoyée au recruteur (simulée).
class SentCompanyNotification {
  const SentCompanyNotification({
    required this.companyId,
    required this.recipient,
    required this.status,
    required this.reason,
  });

  final String companyId;
  final String recipient;
  final CompanyStatus status;
  final String reason;
}

/// Implémentation SIMULÉE de [AdminCompanyRepository], en attendant l'API.
///
/// Reproduit le comportement attendu du serveur : recherche, filtres, tri et
/// pagination, suppression logique, e-mails au recruteur (gardés dans
/// [sentNotifications] au lieu d'être envoyés).
class FakeAdminCompanyRepository implements AdminCompanyRepository {
  FakeAdminCompanyRepository({
    this.latency = const Duration(milliseconds: 600),
    List<AdminCompany>? seed,
  }) : _companies = [...(seed ?? _seed())];

  /// Délai simulé de chaque appel (mettre `Duration.zero` dans les tests).
  final Duration latency;

  final List<AdminCompany> _companies;
  final Set<String> _deletedIds = {};
  int _nextId = 1000;

  /// E-mails qui auraient été envoyés aux recruteurs.
  final List<SentCompanyNotification> sentNotifications = [];

  /// Entreprises supprimées logiquement (conservées pour l'historique).
  Set<String> get deletedIds => Set.unmodifiable(_deletedIds);

  Future<void> _network() => Future<void>.delayed(latency);

  @override
  Future<CompanyPage> fetchCompanies(CompanyQuery query) async {
    await _network();
    final search = query.search.trim().toLowerCase();
    final searchDigits = search.replaceAll(RegExp(r'\s'), '');

    final filtered = _companies.where((company) {
      if (_deletedIds.contains(company.id)) return false;
      if (!query.status.matches(company.status)) return false;
      if (query.sector != null && company.sector != query.sector) return false;
      if (search.isEmpty) return true;
      return company.name.toLowerCase().contains(search) ||
          (searchDigits.isNotEmpty && company.siret.contains(searchDigits));
    }).toList();

    filtered.sort((a, b) {
      final comparison = query.sort.byName
          ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
          : a.createdAt.compareTo(b.createdAt);
      return query.sort.ascending ? comparison : -comparison;
    });

    final start = (query.page - 1) * query.pageSize;
    final items = start >= filtered.length
        ? <AdminCompany>[]
        : filtered.skip(start).take(query.pageSize).toList();
    return CompanyPage(
      items: items,
      total: filtered.length,
      page: query.page,
      pageSize: query.pageSize,
    );
  }

  @override
  Future<AdminCompany> createCompany(CompanyDraft draft) async {
    await _network();
    _ensureUniqueSiret(draft.siret);
    final company = AdminCompany(
      id: 'cmp-${_nextId++}',
      name: draft.name,
      siret: draft.siret,
      sector: draft.sector,
      city: draft.city,
      address: draft.address,
      website: draft.website,
      logo: draft.logo,
      createdAt: DateTime.now(),
      status: draft.initialStatus,
    );
    _companies.add(company);
    return company;
  }

  @override
  Future<AdminCompany> updateCompany(String id, CompanyDraft draft) async {
    await _network();
    final index = _indexOf(id);
    _ensureUniqueSiret(draft.siret, exceptId: id);
    final updated = _companies[index].copyWith(
      name: draft.name,
      siret: draft.siret,
      sector: draft.sector,
      city: draft.city,
      address: draft.address,
      website: draft.website,
      logo: draft.logo,
    );
    _companies[index] = updated;
    return updated;
  }

  @override
  Future<AdminCompany> updateStatus(
    String id,
    CompanyStatus status, {
    String? reason,
  }) async {
    await _network();
    final needsReason =
        status == CompanyStatus.rejected || status == CompanyStatus.suspended;
    if (needsReason && (reason == null || reason.trim().isEmpty)) {
      throw const AdminCompanyException(
        'Un motif est obligatoire pour rejeter ou suspendre.',
        statusCode: 422,
      );
    }
    final index = _indexOf(id);
    final updated = _companies[index].copyWith(
      status: status,
      statusReason: reason,
    );
    _companies[index] = updated;

    final recipient = updated.recruiterEmail;
    if (needsReason && recipient != null) {
      sentNotifications.add(
        SentCompanyNotification(
          companyId: id,
          recipient: recipient,
          status: status,
          reason: reason!.trim(),
        ),
      );
    }
    return updated;
  }

  @override
  Future<void> deleteCompany(String id) async {
    await _network();
    _indexOf(id);
    _deletedIds.add(id);
  }

  int _indexOf(String id) {
    final index = _companies.indexWhere(
      (company) => company.id == id && !_deletedIds.contains(company.id),
    );
    if (index == -1) {
      throw const AdminCompanyException(
        'Cette entreprise n’existe plus.',
        statusCode: 404,
      );
    }
    return index;
  }

  void _ensureUniqueSiret(String siret, {String? exceptId}) {
    final taken = _companies.any(
      (company) =>
          company.siret == siret &&
          company.id != exceptId &&
          !_deletedIds.contains(company.id),
    );
    if (taken) {
      throw const AdminCompanyException(
        'Une entreprise est déjà enregistrée avec ce SIRET.',
        statusCode: 409,
      );
    }
  }

  /// Jeu de données de démonstration (SIRET fictifs, clés de contrôle valides).
  static List<AdminCompany> _seed() {
    const names = [
      ('Nébula Pay', 'Fintech', 'Paris', 'Camille Roux', 'nebulapay.fr'),
      (
        'Kôr Mobility',
        'Mobilité',
        'Nantes',
        'Julien Dubois',
        'kor-mobility.fr',
      ),
      ('Orbe Studio', 'Conseil', 'Lyon', 'Inès Rahmani', 'orbe.studio'),
      (
        'Talent Express',
        'Recrutement',
        'Lille',
        'Marc Tessier',
        'talent-express.fr',
      ),
      ('Lumen Santé', 'Santé', 'Lyon', 'Amine Diallo', 'lumen-sante.fr'),
      ('Pixelune', 'Jeux vidéo', 'Bordeaux', 'Léa Martin', 'pixelune.io'),
      (
        'Vertigo Labs',
        'Jeux vidéo',
        'Montpellier',
        'Hugo Leroy',
        'vertigolabs.fr',
      ),
      ('Sillon Bank', 'Banque', 'Paris', 'Sarah Benali', 'sillonbank.fr'),
      (
        'Maison Grenat',
        'Retail',
        'Marseille',
        'Chloé Petit',
        'maisongrenat.fr',
      ),
      (
        'Atelier Brique',
        'Industrie',
        'Toulouse',
        'Nathan Moreau',
        'atelier-brique.fr',
      ),
    ];
    const statuses = [
      CompanyStatus.approved,
      CompanyStatus.approved,
      CompanyStatus.pending,
      CompanyStatus.approved,
      CompanyStatus.suspended,
      CompanyStatus.approved,
      CompanyStatus.pending,
      CompanyStatus.rejected,
      CompanyStatus.approved,
      CompanyStatus.pending,
    ];
    final now = DateTime(2026, 11, 1, 10);
    final companies = <AdminCompany>[];
    for (var i = 0; i < 45; i++) {
      final (name, sector, city, recruiter, domain) = names[i % names.length];
      final suffix = i < names.length ? '' : ' ${i ~/ names.length + 1}';
      final status = statuses[i % statuses.length];
      companies.add(
        AdminCompany(
          id: 'cmp-${i + 1}',
          name: '$name$suffix',
          siret: _validSiret(i),
          sector: sector,
          city: city,
          address: '${10 + i} rue de la République, $city',
          website: 'https://$domain',
          createdAt: now.subtract(Duration(days: i * 3, hours: i)),
          status: status,
          recruiterName: recruiter,
          recruiterEmail: '${recruiter.split(' ').first.toLowerCase()}@$domain',
          statusReason: switch (status) {
            CompanyStatus.rejected => 'Informations légales invalides',
            CompanyStatus.suspended => 'Entreprise inactive',
            _ => null,
          },
        ),
      );
    }
    return companies;
  }

  /// Fabrique un SIRET fictif dont la clé de Luhn est valide.
  static String _validSiret(int index) {
    final base = (100000000000 + index * 7919).toString().padLeft(13, '0');
    for (var check = 0; check < 10; check++) {
      final candidate = '$base$check';
      if (_luhn(candidate)) return candidate;
    }
    return '${base}0';
  }

  static bool _luhn(String digits) {
    var sum = 0;
    for (var i = 0; i < digits.length; i++) {
      var value = int.parse(digits[digits.length - 1 - i]);
      if (i.isOdd) {
        value *= 2;
        if (value > 9) value -= 9;
      }
      sum += value;
    }
    return sum % 10 == 0;
  }
}
