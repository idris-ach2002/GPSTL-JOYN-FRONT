import 'package:flutter/foundation.dart';

import 'job_offer.dart';

@immutable
class JobOfferDraft {
  const JobOfferDraft({
    required this.companyId,
    required this.title,
    required this.contractType,
    required this.location,
    required this.remoteMode,
    required this.experienceLevel,
    required this.description,
    required this.skills,
    this.salaryMin,
    this.salaryMax,
    this.currency = 'EUR',
    this.salaryPeriod = SalaryPeriod.year,
    this.rhythmType,
    this.startDate,
    this.durationMonths,
    this.degreeLevelRequired,
  });

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
}
