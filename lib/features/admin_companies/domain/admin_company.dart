import 'package:flutter/foundation.dart';

/// Statut de modération d'une entreprise.
enum CompanyStatus {
  pending('En attente de validation', 'pending'),
  approved('Validée', 'approved'),
  rejected('Rejetée', 'rejected'),
  suspended('Suspendue', 'suspended');

  const CompanyStatus(this.label, this.apiValue);

  final String label;

  /// Valeur échangée avec l'API.
  final String apiValue;

  static CompanyStatus fromApi(String? value) =>
      CompanyStatus.values.firstWhere(
        (status) =>
            status.apiValue == value?.toLowerCase() ||
            (status == CompanyStatus.approved &&
                value?.toUpperCase() == 'VERIFIED') ||
            (status == CompanyStatus.pending &&
                value?.toUpperCase() == 'NOT_VERIFIED') ||
            (status == CompanyStatus.rejected &&
                value?.toUpperCase() == 'REJECTED'),
        orElse: () => pending,
      );
}

/// Logo d'une entreprise : une image choisie localement, ou une URL.
@immutable
class CompanyLogo {
  const CompanyLogo({this.bytes, this.url, this.fileName});

  final Uint8List? bytes;
  final String? url;
  final String? fileName;

  bool get isEmpty => bytes == null && (url == null || url!.isEmpty);
}

/// Entreprise telle que l'administration la voit.
@immutable
class AdminCompany {
  const AdminCompany({
    required this.id,
    required this.name,
    required this.siret,
    required this.sector,
    required this.city,
    required this.createdAt,
    required this.status,
    this.address = '',
    this.website = '',
    this.logo,
    this.recruiterName,
    this.recruiterEmail,
    this.statusReason,
  });

  final String id;

  /// Raison sociale ou nom d'usage.
  final String name;

  /// 14 chiffres, sans espaces.
  final String siret;
  final String sector;
  final String city;
  final String address;
  final String website;
  final CompanyLogo? logo;
  final DateTime createdAt;
  final CompanyStatus status;

  /// Recruteur à l'origine de l'inscription (`null` si créée par un admin).
  final String? recruiterName;
  final String? recruiterEmail;

  /// Dernier motif de rejet ou de suspension.
  final String? statusReason;

  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    final letters = words.where((w) => w.isNotEmpty).take(2).map((w) => w[0]);
    final value = letters.join().toUpperCase();
    return value.isEmpty ? '?' : value;
  }

  AdminCompany copyWith({
    String? name,
    String? siret,
    String? sector,
    String? city,
    String? address,
    String? website,
    CompanyLogo? logo,
    CompanyStatus? status,
    String? statusReason,
  }) {
    return AdminCompany(
      id: id,
      name: name ?? this.name,
      siret: siret ?? this.siret,
      sector: sector ?? this.sector,
      city: city ?? this.city,
      address: address ?? this.address,
      website: website ?? this.website,
      logo: logo ?? this.logo,
      createdAt: createdAt,
      status: status ?? this.status,
      recruiterName: recruiterName,
      recruiterEmail: recruiterEmail,
      statusReason: statusReason ?? this.statusReason,
    );
  }
}

/// Données saisies dans le formulaire de création ou de modification.
@immutable
class CompanyDraft {
  const CompanyDraft({
    required this.name,
    required this.siret,
    required this.sector,
    required this.city,
    this.address = '',
    this.website = '',
    this.logo,
    this.initialStatus = CompanyStatus.pending,
  });

  final String name;

  /// 14 chiffres, sans espaces.
  final String siret;
  final String sector;
  final String city;
  final String address;
  final String website;
  final CompanyLogo? logo;

  /// Statut à la création (ignoré en modification).
  final CompanyStatus initialStatus;
}

/// Filtre de statut de la liste.
enum CompanyStatusFilter {
  all('Toutes', null),
  pending('En attente', 'pending'),
  approved('Validées', 'approved'),
  rejectedOrSuspended('Rejetées / suspendues', 'rejected,suspended');

  const CompanyStatusFilter(this.label, this.apiValue);

  final String label;

  /// Valeur du paramètre `status` de l'API (`null` = pas de filtre).
  final String? apiValue;

  bool matches(CompanyStatus status) => switch (this) {
    CompanyStatusFilter.all => true,
    CompanyStatusFilter.pending => status == CompanyStatus.pending,
    CompanyStatusFilter.approved => status == CompanyStatus.approved,
    CompanyStatusFilter.rejectedOrSuspended =>
      status == CompanyStatus.rejected || status == CompanyStatus.suspended,
  };
}

/// Tri de la liste.
enum CompanySort {
  newest('Plus récentes', 'createdAt', 'desc'),
  oldest('Plus anciennes', 'createdAt', 'asc'),
  nameAsc('Nom A → Z', 'name', 'asc'),
  nameDesc('Nom Z → A', 'name', 'desc');

  const CompanySort(this.label, this.field, this.direction);

  final String label;
  final String field;
  final String direction;

  bool get byName => field == 'name';
  bool get ascending => direction == 'asc';
}

/// Paramètres d'une page de résultats (pagination côté serveur).
@immutable
class CompanyQuery {
  const CompanyQuery({
    this.page = 1,
    this.pageSize = defaultPageSize,
    this.search = '',
    this.status = CompanyStatusFilter.all,
    this.sector,
    this.sort = CompanySort.newest,
  });

  static const int defaultPageSize = 20;

  final int page;
  final int pageSize;

  /// Recherche sur le nom et le SIRET.
  final String search;
  final CompanyStatusFilter status;

  /// `null` = tous les secteurs.
  final String? sector;
  final CompanySort sort;

  CompanyQuery copyWith({
    int? page,
    String? search,
    CompanyStatusFilter? status,
    String? sector,
    bool clearSector = false,
    CompanySort? sort,
  }) {
    return CompanyQuery(
      page: page ?? this.page,
      pageSize: pageSize,
      search: search ?? this.search,
      status: status ?? this.status,
      sector: clearSector ? null : sector ?? this.sector,
      sort: sort ?? this.sort,
    );
  }
}

/// Une page de résultats renvoyée par le serveur.
@immutable
class CompanyPage {
  const CompanyPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<AdminCompany> items;

  /// Nombre total de résultats pour les filtres courants.
  final int total;
  final int page;
  final int pageSize;

  int get totalPages => total == 0 ? 1 : (total / pageSize).ceil();

  /// Index (à partir de 1) du premier et du dernier résultat affichés.
  int get firstIndex => items.isEmpty ? 0 : (page - 1) * pageSize + 1;
  int get lastIndex => items.isEmpty ? 0 : firstIndex + items.length - 1;
}
