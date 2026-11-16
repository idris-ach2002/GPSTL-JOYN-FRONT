/// Type de contrat recherché (codes `contract_types` du back).
enum ContractType {
  apprenticeship('APPRENTICESHIP', 'Apprentissage'),
  professionalization('PROFESSIONALIZATION', 'Contrat pro'),
  internship('INTERNSHIP', 'Stage'),
  cdi('CDI', 'CDI'),
  cdd('CDD', 'CDD'),
  freelance('FREELANCE', 'Freelance'),
  temporary('TEMPORARY', 'Intérim');

  const ContractType(this.code, this.label);

  final String code;
  final String label;

  static ContractType? fromCode(String? code) =>
      values.where((c) => c.code == code?.trim().toUpperCase()).firstOrNull;
}

/// Politique de télétravail souhaitée (`remote_policy` du back).
enum RemotePolicy {
  onsite('ONSITE', 'Sur site'),
  hybrid('HYBRID', 'Hybride'),
  remote('REMOTE', 'Télétravail complet');

  const RemotePolicy(this.code, this.label);

  final String code;
  final String label;

  static RemotePolicy? fromCode(String? code) =>
      values.where((c) => c.code == code?.trim().toUpperCase()).firstOrNull;
}

/// Qui peut voir le profil (`visibility` du back).
class VisibilitySettings {
  const VisibilitySettings({
    this.visibleToRecruiters = true,
    this.visibleToOthers = true,
    this.showLastName = true,
    this.showContactLinks = true,
  });

  /// Le profil apparaît dans les recommandations des recruteurs.
  final bool visibleToRecruiters;

  /// Le profil est visible des autres utilisateurs (hors recruteurs).
  final bool visibleToOthers;

  /// Le nom de famille est affiché ; sinon seulement son initiale.
  final bool showLastName;

  /// GitHub, LinkedIn et portfolio sont visibles.
  final bool showContactLinks;

  VisibilitySettings copyWith({
    bool? visibleToRecruiters,
    bool? visibleToOthers,
    bool? showLastName,
    bool? showContactLinks,
  }) => VisibilitySettings(
    visibleToRecruiters: visibleToRecruiters ?? this.visibleToRecruiters,
    visibleToOthers: visibleToOthers ?? this.visibleToOthers,
    showLastName: showLastName ?? this.showLastName,
    showContactLinks: showContactLinks ?? this.showContactLinks,
  );

  Map<String, Object?> toApi() => {
    'visible_to_recruiters': visibleToRecruiters,
    'visible_to_others': visibleToOthers,
    'show_last_name': showLastName,
    'show_contact_links': showContactLinks,
  };

  @override
  bool operator ==(Object other) =>
      other is VisibilitySettings &&
      other.visibleToRecruiters == visibleToRecruiters &&
      other.visibleToOthers == visibleToOthers &&
      other.showLastName == showLastName &&
      other.showContactLinks == showContactLinks;

  @override
  int get hashCode => Object.hash(
    visibleToRecruiters,
    visibleToOthers,
    showLastName,
    showContactLinks,
  );
}

/// Critères de recherche qui orientent les recommandations
/// (`preferences` du back).
class SearchPreferences {
  const SearchPreferences({
    this.contractTypes = const {},
    this.remotePolicy,
    this.minSalary,
  });

  final Set<ContractType> contractTypes;

  /// `null` : indifférent.
  final RemotePolicy? remotePolicy;

  /// Rémunération minimum, en euros bruts par mois. `null` : aucun minimum.
  final int? minSalary;

  SearchPreferences copyWith({
    Set<ContractType>? contractTypes,
    RemotePolicy? remotePolicy,
    bool clearRemote = false,
    int? minSalary,
    bool clearSalary = false,
  }) => SearchPreferences(
    contractTypes: contractTypes ?? this.contractTypes,
    remotePolicy: clearRemote ? null : remotePolicy ?? this.remotePolicy,
    minSalary: clearSalary ? null : minSalary ?? this.minSalary,
  );

  Map<String, Object?> toApi() => {
    'contract_types': [for (final c in contractTypes) c.code]..sort(),
    'remote_policy': remotePolicy?.code,
    'min_salary': minSalary,
    'currency': 'EUR',
  };

  @override
  bool operator ==(Object other) =>
      other is SearchPreferences &&
      other.remotePolicy == remotePolicy &&
      other.minSalary == minSalary &&
      other.contractTypes.length == contractTypes.length &&
      other.contractTypes.containsAll(contractTypes);

  @override
  int get hashCode => Object.hash(
    remotePolicy,
    minSalary,
    Object.hashAllUnordered(contractTypes),
  );
}

/// Paramètres du candidat connecté.
class CandidateSettings {
  const CandidateSettings({
    this.email = '',
    this.visibility = const VisibilitySettings(),
    this.preferences = const SearchPreferences(),
  });

  final String email;
  final VisibilitySettings visibility;
  final SearchPreferences preferences;

  CandidateSettings copyWith({
    VisibilitySettings? visibility,
    SearchPreferences? preferences,
  }) => CandidateSettings(
    email: email,
    visibility: visibility ?? this.visibility,
    preferences: preferences ?? this.preferences,
  );
}
