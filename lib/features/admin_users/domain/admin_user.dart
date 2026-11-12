import 'package:flutter/foundation.dart';

/// Rôle d'un compte sur la plateforme.
enum AccountRole {
  candidate('Candidat', 'candidate'),
  recruiter('Recruteur', 'recruiter'),
  admin('Admin', 'admin');

  const AccountRole(this.label, this.apiValue);

  final String label;
  final String apiValue;

  static AccountRole fromApi(String? value) => AccountRole.values.firstWhere(
    (role) => role.apiValue == value?.toLowerCase(),
    orElse: () => candidate,
  );
}

/// Statut d'un compte.
enum AccountStatus {
  active('Actif', 'active'),
  pending('En attente', 'pending'),
  suspended('Suspendu', 'suspended'),
  banned('Banni', 'banned');

  const AccountStatus(this.label, this.apiValue);

  final String label;
  final String apiValue;

  static AccountStatus fromApi(String? value) => AccountStatus.values
      .firstWhere((status) => status.apiValue == value?.toLowerCase(), orElse: () => active);
}

/// Type d'entrée du journal de modération.
enum ModerationKind {
  suspended('Suspension'),
  banned('Bannissement'),
  reactivated('Réactivation'),
  roleChanged('Changement de rôle');

  const ModerationKind(this.label);

  final String label;
}

/// Une sanction ou une décision de modération passée.
@immutable
class ModerationEntry {
  const ModerationEntry({
    required this.kind,
    required this.date,
    required this.author,
    this.reason = '',
  });

  final ModerationKind kind;
  final DateTime date;

  /// Administrateur à l'origine de la décision.
  final String author;
  final String reason;
}

/// Compte utilisateur tel que l'administration le voit.
@immutable
class AdminUserAccount {
  const AdminUserAccount({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.status,
    required this.createdAt,
    this.emailVerified = true,
    this.avatarUrl,
    this.companyId,
    this.companyName,
    this.lastLoginAt,
    this.applicationsCount = 0,
    this.offersCount = 0,
    this.moderationHistory = const [],
  });

  /// Identifiant technique (UUID).
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final AccountRole role;
  final AccountStatus status;
  final bool emailVerified;
  final String? avatarUrl;

  /// Entreprise rattachée (recruteurs).
  final String? companyId;
  final String? companyName;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  /// Candidatures envoyées (candidats).
  final int applicationsCount;

  /// Offres créées (recruteurs).
  final int offersCount;
  final List<ModerationEntry> moderationHistory;

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  String get initials {
    final first = firstName.trim();
    final last = lastName.trim();
    final value =
        '${first.isEmpty ? '' : first[0]}${last.isEmpty ? '' : last[0]}';
    return value.isEmpty ? '?' : value.toUpperCase();
  }

  AdminUserAccount copyWith({
    AccountRole? role,
    AccountStatus? status,
    List<ModerationEntry>? moderationHistory,
  }) {
    return AdminUserAccount(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt,
      emailVerified: emailVerified,
      avatarUrl: avatarUrl,
      companyId: companyId,
      companyName: companyName,
      lastLoginAt: lastLoginAt,
      applicationsCount: applicationsCount,
      offersCount: offersCount,
      moderationHistory: moderationHistory ?? this.moderationHistory,
    );
  }
}
