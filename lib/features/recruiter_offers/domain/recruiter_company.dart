import 'package:flutter/foundation.dart';

@immutable
class RecruiterCompany {
  const RecruiterCompany({
    required this.id,
    required this.name,
    required this.siret,
    required this.activity,
    required this.sector,
    required this.sizeRange,
    required this.city,
    this.website,
    this.description = '',
  });

  final int id;
  final String name;
  final String siret;
  final String activity;
  final String sector;
  final String sizeRange;
  final String city;
  final String? website;
  final String description;

  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

@immutable
class RecruiterCompanyDraft {
  const RecruiterCompanyDraft({
    required this.name,
    required this.sector,
    required this.sizeRange,
    required this.city,
    this.siret = '',
    this.website = '',
    this.description = '',
  });

  final String name;
  final String sector;
  final String sizeRange;
  final String city;
  final String siret;
  final String website;
  final String description;
}
