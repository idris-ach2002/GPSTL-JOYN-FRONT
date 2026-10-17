import 'package:flutter/foundation.dart';

/// Données saisies pour créer un espace entreprise.
@immutable
class CompanyAccountDraft {
  const CompanyAccountDraft({
    required this.siret,
    required this.sector,
    required this.sizeRange,
    required this.firstName,
    required this.lastName,
    required this.jobTitle,
    required this.email,
    required this.password,
    required this.acceptedTerms,
    this.phone,
  });

  /// 14 chiffres, sans espaces.
  final String siret;
  final String? sector;
  final String? sizeRange;
  final String firstName;
  final String lastName;
  final String jobTitle;
  final String email;
  final String password;
  final bool acceptedTerms;

  /// Téléphone, `null` si non renseigné.
  final String? phone;
}
