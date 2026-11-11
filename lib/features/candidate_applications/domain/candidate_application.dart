/// Étape d'une candidature, une colonne par valeur sur l'écran.
enum ApplicationStatus {
  /// Offre aimée, candidature pas encore envoyée.
  interested('Intéressé'),
  sent('Candidatures envoyées'),
  interview('Entretiens'),
  rejected('Refus');

  const ApplicationStatus(this.label);

  /// Titre de la colonne.
  final String label;

  /// Conversion du statut renvoyé par l'API.
  ///
  /// TODO(backend): ajuster les valeurs quand le contrat de l'API sera fixé.
  /// Un statut inconnu est traité comme « envoyée ».
  static ApplicationStatus fromApi(String? value) {
    return switch (value?.trim().toUpperCase()) {
      'INTERESTED' || 'LIKED' => ApplicationStatus.interested,
      'INTERVIEW' || 'INTERVIEW_SCHEDULED' => ApplicationStatus.interview,
      'REJECTED' || 'REFUSED' || 'DECLINED' => ApplicationStatus.rejected,
      _ => ApplicationStatus.sent,
    };
  }
}

/// Une candidature du candidat connecté.
///
/// Seuls [id] et [status] sont obligatoires : les autres champs valent `null`
/// tant que le backend ne les fournit pas, et l'écran affiche un tiret.
class CandidateApplication {
  const CandidateApplication({
    required this.id,
    required this.status,
    this.offerId,
    this.companyName,
    this.companyLogoUrl,
    this.jobTitle,
    this.matchScore,
    this.appliedAt,
    this.interviewAt,
    this.conversationId,
  });

  final String id;
  final ApplicationStatus status;
  final String? offerId;
  final String? companyName;
  final String? companyLogoUrl;
  final String? jobTitle;

  /// Score de match avec l'offre, de 0 à 100.
  final int? matchScore;

  /// Date d'envoi (ou de l'intérêt pour la colonne « Intéressé »).
  final DateTime? appliedAt;
  final DateTime? interviewAt;

  /// Fil de discussion avec le recruteur, s'il existe déjà.
  final String? conversationId;

  bool get hasConversation =>
      conversationId != null && conversationId!.trim().isNotEmpty;

  /// Une conversation peut être créée seulement à l'étape entretien.
  ///
  /// TODO(backend): confirmer la règle métier avec l'équipe back.
  bool get canStartConversation => status == ApplicationStatus.interview;

  CandidateApplication copyWith({
    String? conversationId,
    ApplicationStatus? status,
    DateTime? appliedAt,
  }) {
    return CandidateApplication(
      id: id,
      status: status ?? this.status,
      offerId: offerId,
      companyName: companyName,
      companyLogoUrl: companyLogoUrl,
      jobTitle: jobTitle,
      matchScore: matchScore,
      appliedAt: appliedAt ?? this.appliedAt,
      interviewAt: interviewAt,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}

/// Une page de résultats (l'API est paginée).
class ApplicationsPage {
  const ApplicationsPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalItems,
  });

  static const ApplicationsPage empty = ApplicationsPage(
    items: [],
    page: 1,
    totalPages: 1,
    totalItems: 0,
  );

  final List<CandidateApplication> items;

  /// Numéro de page, à partir de 1.
  final int page;
  final int totalPages;
  final int totalItems;

  bool get hasMore => page < totalPages;
}
