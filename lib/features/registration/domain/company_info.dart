import 'package:flutter/foundation.dart';

/// Entreprise retrouvée à partir de son SIRET.
@immutable
class CompanyInfo {
  const CompanyInfo({
    required this.siret,
    required this.legalName,
    required this.displayName,
    required this.city,
    required this.activity,
    required this.emailDomain,
    this.sector,
    this.sizeRange,
  });

  /// 14 chiffres, sans espaces.
  final String siret;

  /// Raison sociale : « Alex Dupont SAS ».
  final String legalName;

  /// Nom d'usage : « Alex Dupont ».
  final String displayName;
  final String city;

  /// Activité déclarée : « Services de paiement ».
  final String activity;

  /// Domaine des adresses e-mail de l'entreprise : « nebulapay.fr ».
  final String emailDomain;

  /// Secteur proposé par défaut dans le formulaire.
  final String? sector;

  /// Tranche d'effectif proposée par défaut.
  final String? sizeRange;

  String get initial =>
      displayName.isEmpty ? '?' : displayName[0].toUpperCase();
}
