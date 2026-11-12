import 'package:flutter/foundation.dart';

/// Où en est la vérification d'une entreprise.
enum VerificationStatus {
  /// La vérification automatique a échoué : un admin doit trancher.
  toReview('À vérifier', 'to_review'),

  /// Un justificatif a été demandé au recruteur.
  documentRequested('Justificatif demandé', 'document_requested'),

  /// Validée automatiquement par l'API SIRENE.
  verifiedAuto('Vérifiée (auto)', 'verified_auto'),

  /// Validée manuellement par un admin.
  verifiedManual('Vérifiée (manuel)', 'verified_manual'),

  refused('Refusée', 'refused');

  const VerificationStatus(this.label, this.apiValue);

  final String label;
  final String apiValue;

  bool get isOpen => this == toReview || this == documentRequested;

  static VerificationStatus fromApi(String? value) => VerificationStatus.values
      .firstWhere((status) => status.apiValue == value, orElse: () => toReview);
}

/// Pourquoi la vérification automatique n'a pas abouti.
enum VerificationIssue {
  apiUnavailable('API SIRENE indisponible'),
  siretNotFound('SIRET introuvable'),
  establishmentClosed('Établissement fermé'),
  nameMismatch('Raison sociale différente'),
  genericEmailDomain('E-mail non professionnel'),
  none('Aucun problème');

  const VerificationIssue(this.label);

  final String label;
}

/// Résultat d'un contrôle automatique.
enum CheckOutcome { passed, failed, unavailable }

/// Un contrôle fait par l'API (SIRET actif, raison sociale, adresse…).
@immutable
class VerificationCheck {
  const VerificationCheck({
    required this.label,
    required this.outcome,
    this.detail = '',
  });

  final String label;
  final CheckOutcome outcome;
  final String detail;
}

/// Décision prise sur une vérification (historique).
@immutable
class VerificationEvent {
  const VerificationEvent({
    required this.label,
    required this.date,
    required this.author,
    this.note = '',
  });

  final String label;
  final DateTime date;

  /// « Système » pour la vérification automatique, sinon l'admin.
  final String author;
  final String note;
}

/// Une demande de vérification d'entreprise.
@immutable
class CompanyVerification {
  const CompanyVerification({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.siret,
    required this.city,
    required this.submittedAt,
    required this.status,
    required this.issue,
    this.registryName,
    this.registryAddress,
    this.declaredAddress = '',
    this.recruiterName,
    this.recruiterEmail,
    this.apiMessage,
    this.checks = const [],
    this.history = const [],
  });

  final String id;
  final String companyId;

  /// Raison sociale déclarée à l'inscription.
  final String companyName;
  final String siret;
  final String city;
  final DateTime submittedAt;
  final VerificationStatus status;
  final VerificationIssue issue;

  /// Données du registre (`null` si l'API n'a rien renvoyé).
  final String? registryName;
  final String? registryAddress;
  final String declaredAddress;
  final String? recruiterName;
  final String? recruiterEmail;

  /// Message technique renvoyé par l'API (erreur, délai dépassé…).
  final String? apiMessage;
  final List<VerificationCheck> checks;
  final List<VerificationEvent> history;

  String get initials {
    final words = companyName.trim().split(RegExp(r'\s+'));
    final value = words
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join()
        .toUpperCase();
    return value.isEmpty ? '?' : value;
  }

  CompanyVerification copyWith({
    VerificationStatus? status,
    VerificationIssue? issue,
    String? registryName,
    String? registryAddress,
    String? apiMessage,
    bool clearApiMessage = false,
    List<VerificationCheck>? checks,
    List<VerificationEvent>? history,
  }) {
    return CompanyVerification(
      id: id,
      companyId: companyId,
      companyName: companyName,
      siret: siret,
      city: city,
      submittedAt: submittedAt,
      status: status ?? this.status,
      issue: issue ?? this.issue,
      registryName: registryName ?? this.registryName,
      registryAddress: registryAddress ?? this.registryAddress,
      declaredAddress: declaredAddress,
      recruiterName: recruiterName,
      recruiterEmail: recruiterEmail,
      apiMessage: clearApiMessage ? null : apiMessage ?? this.apiMessage,
      checks: checks ?? this.checks,
      history: history ?? this.history,
    );
  }
}

/// Filtre de la file.
enum VerificationFilter {
  toReview('À traiter'),
  documentRequested('Justificatif demandé'),
  done('Traitées'),
  all('Toutes');

  const VerificationFilter(this.label);

  final String label;

  bool matches(VerificationStatus status) => switch (this) {
    VerificationFilter.toReview => status == VerificationStatus.toReview,
    VerificationFilter.documentRequested =>
      status == VerificationStatus.documentRequested,
    VerificationFilter.done => !status.isOpen,
    VerificationFilter.all => true,
  };

  /// Valeur du paramètre `status` de l'API.
  String? get apiValue => switch (this) {
    VerificationFilter.toReview => 'to_review',
    VerificationFilter.documentRequested => 'document_requested',
    VerificationFilter.done => 'verified_auto,verified_manual,refused',
    VerificationFilter.all => null,
  };
}

/// Décision manuelle d'un admin.
enum VerificationDecision {
  approve('approve'),
  requestDocument('request_document'),
  refuse('refuse');

  const VerificationDecision(this.apiValue);

  final String apiValue;
}

/// Listes de choix des modales.
abstract final class VerificationOptions {
  static const documents = [
    'Extrait Kbis de moins de 3 mois',
    'Avis de situation SIRENE',
    'Justificatif d’adresse du siège',
  ];

  static const refusalReasons = [
    'SIRET invalide ou inexistant',
    'Établissement fermé',
    'Entreprise différente de celle déclarée',
    'Suspicion de fraude',
  ];

  static const searchDebounce = Duration(milliseconds: 300);
}
