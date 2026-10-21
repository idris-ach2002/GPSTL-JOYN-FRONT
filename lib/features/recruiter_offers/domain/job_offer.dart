import 'package:flutter/foundation.dart';

enum ContractType {
  cdi('CDI', 'CDI'),
  cdd('CDD', 'CDD'),
  internship('INTERNSHIP', 'Stage'),
  apprenticeship('APPRENTICESHIP', 'Alternance'),
  professionalization('PROFESSIONALIZATION', 'Contrat de professionnalisation'),
  freelance('FREELANCE', 'Freelance'),
  temporary('TEMPORARY', 'Intérim');

  const ContractType(this.apiValue, this.label);
  final String apiValue;
  final String label;

  bool get isWorkStudy => this == ContractType.apprenticeship || this == ContractType.professionalization;
}

enum RemoteMode {
  onsite('ONSITE', 'Présentiel'),
  hybrid('HYBRID', 'Hybride'),
  remote('REMOTE', 'Télétravail');

  const RemoteMode(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

enum ExperienceLevel {
  junior('JUNIOR', 'Junior'),
  mid('MID', 'Intermédiaire'),
  senior('SENIOR', 'Senior');

  const ExperienceLevel(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

enum SalaryPeriod {
  hour('HOUR', 'Horaire'),
  month('MONTH', 'Mensuel'),
  year('YEAR', 'Annuel');

  const SalaryPeriod(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

enum JobOfferStatus {
  draft('DRAFT', 'Brouillon'),
  published('PUBLISHED', 'Publiée'),
  closed('CLOSED', 'Clôturée'),
  archived('ARCHIVED', 'Archivée');

  const JobOfferStatus(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

@immutable
class JobOffer {
  const JobOffer({
    required this.id,
    required this.companyId,
    required this.title,
    required this.contractType,
    required this.location,
    required this.remoteMode,
    required this.experienceLevel,
    required this.description,
    required this.skills,
    required this.status,
    required this.updatedAt,
    this.salaryMin,
    this.salaryMax,
    this.currency = 'EUR',
    this.salaryPeriod = SalaryPeriod.year,
    this.rhythmType,
    this.startDate,
    this.durationMonths,
    this.degreeLevelRequired,
    this.publishedAt,
    this.candidateCount = 0,
  });

  final int id;
  final int companyId;
  final String title;
  final ContractType contractType;
  final String location;
  final RemoteMode remoteMode;
  final ExperienceLevel experienceLevel;
  final String description;
  final double? salaryMin;
  final double? salaryMax;
  final String currency;
  final SalaryPeriod salaryPeriod;
  final List<String> skills;
  final String? rhythmType;
  final DateTime? startDate;
  final int? durationMonths;
  final String? degreeLevelRequired;
  final JobOfferStatus status;
  final DateTime? publishedAt;
  final DateTime updatedAt;
  final int candidateCount;

  JobOffer copyWith({
    int? companyId,
    String? title,
    ContractType? contractType,
    String? location,
    RemoteMode? remoteMode,
    ExperienceLevel? experienceLevel,
    String? description,
    double? salaryMin,
    double? salaryMax,
    String? currency,
    SalaryPeriod? salaryPeriod,
    List<String>? skills,
    String? rhythmType,
    DateTime? startDate,
    int? durationMonths,
    String? degreeLevelRequired,
    JobOfferStatus? status,
    DateTime? publishedAt,
    DateTime? updatedAt,
    int? candidateCount,
  }) => JobOffer(
    id: id,
    companyId: companyId ?? this.companyId,
    title: title ?? this.title,
    contractType: contractType ?? this.contractType,
    location: location ?? this.location,
    remoteMode: remoteMode ?? this.remoteMode,
    experienceLevel: experienceLevel ?? this.experienceLevel,
    description: description ?? this.description,
    salaryMin: salaryMin ?? this.salaryMin,
    salaryMax: salaryMax ?? this.salaryMax,
    currency: currency ?? this.currency,
    salaryPeriod: salaryPeriod ?? this.salaryPeriod,
    skills: skills ?? this.skills,
    rhythmType: rhythmType ?? this.rhythmType,
    startDate: startDate ?? this.startDate,
    durationMonths: durationMonths ?? this.durationMonths,
    degreeLevelRequired: degreeLevelRequired ?? this.degreeLevelRequired,
    status: status ?? this.status,
    publishedAt: publishedAt ?? this.publishedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    candidateCount: candidateCount ?? this.candidateCount,
  );
}
