import 'package:flutter/foundation.dart';

import 'onboarding_options.dart';

/// Profil étudiant construit pendant l'onboarding.
@immutable
class StudentProfileDraft {
  const StudentProfileDraft({
    required this.searchKind,
    required this.degreeTitle,
    required this.school,
    required this.level,
    required this.graduationYear,
    required this.city,
    required this.availableFrom,
    required this.maxCommuteMinutes,
    required this.rhythm,
    required this.domains,
    required this.skills,
    required this.softSkills,
    required this.remoteMode,
    required this.companySizes,
    required this.desiredMonthlySalary,
  });

  final String searchKind;
  final String degreeTitle;
  final String school;
  final String? level;
  final int? graduationYear;
  final String city;
  final String availableFrom;
  final int maxCommuteMinutes;
  final String? rhythm;
  final List<String> domains;
  final Map<String, SkillLevel> skills;
  final List<String> softSkills;
  final String? remoteMode;
  final List<String> companySizes;

  /// Rémunération brute mensuelle souhaitée, `null` si non renseignée.
  final int? desiredMonthlySalary;
}
