import 'package:flutter/foundation.dart';

enum CandidateRecommendationStatus {
  recommended('recommended', 'Recommandés'),
  saved('saved', 'Enregistrés'),
  interested('interested', 'Intéressés'),
  rejected('rejected', 'Écartés'),
  matched('matched', 'Matches');

  const CandidateRecommendationStatus(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static CandidateRecommendationStatus fromApi(String? value) {
    final normalized = value?.trim().toLowerCase();
    return values.firstWhere(
      (item) => item.apiValue == normalized,
      orElse: () => CandidateRecommendationStatus.recommended,
    );
  }
}

@immutable
class RecruiterCandidateOffer {
  const RecruiterCandidateOffer({
    required this.id,
    required this.title,
    required this.location,
    required this.contract,
  });

  final int id;
  final String title;
  final String location;
  final String contract;
}

@immutable
class CandidateMatchBreakdown {
  const CandidateMatchBreakdown({
    required this.skills,
    required this.experience,
    required this.education,
    required this.location,
    required this.availability,
  });

  final double skills;
  final double experience;
  final double education;
  final double location;
  final double availability;

  Iterable<MapEntry<String, double>> get entries => [
    MapEntry('Compétences', skills),
    MapEntry('Expérience', experience),
    MapEntry('Formation', education),
    MapEntry('Localisation', location),
    MapEntry('Disponibilité', availability),
  ];
}

@immutable
class RecruiterCandidateRecommendation {
  const RecruiterCandidateRecommendation({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.jobTitle,
    required this.location,
    required this.education,
    required this.experienceYears,
    required this.availability,
    required this.contractPreference,
    required this.remotePreference,
    required this.skills,
    required this.compatibilityScore,
    required this.match,
    required this.strengths,
    required this.warnings,
    required this.summary,
    required this.status,
    required this.reciprocalMatch,
    required this.connections,
    this.avatarUrl,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String jobTitle;
  final String? avatarUrl;
  final String location;
  final String education;
  final double experienceYears;
  final String availability;
  final String contractPreference;
  final String remotePreference;
  final List<String> skills;
  final double compatibilityScore;
  final CandidateMatchBreakdown match;
  final List<String> strengths;
  final List<String> warnings;
  final String summary;
  final CandidateRecommendationStatus status;
  final bool reciprocalMatch;
  final int connections;

  String get fullName => '$firstName $lastName'.trim();

  RecruiterCandidateRecommendation copyWith({
    CandidateRecommendationStatus? status,
    bool? reciprocalMatch,
  }) => RecruiterCandidateRecommendation(
    id: id,
    firstName: firstName,
    lastName: lastName,
    jobTitle: jobTitle,
    avatarUrl: avatarUrl,
    location: location,
    education: education,
    experienceYears: experienceYears,
    availability: availability,
    contractPreference: contractPreference,
    remotePreference: remotePreference,
    skills: skills,
    compatibilityScore: compatibilityScore,
    match: match,
    strengths: strengths,
    warnings: warnings,
    summary: summary,
    status: status ?? this.status,
    reciprocalMatch: reciprocalMatch ?? this.reciprocalMatch,
    connections: connections,
  );
}

@immutable
class CandidateRecommendationStats {
  const CandidateRecommendationStats({
    required this.recommended,
    required this.saved,
    required this.interested,
    required this.matches,
  });

  final int recommended;
  final int saved;
  final int interested;
  final int matches;
}

@immutable
class CandidateRecommendationQuery {
  const CandidateRecommendationQuery({
    this.offerId,
    this.status = CandidateRecommendationStatus.recommended,
    this.scoreMin = 0,
    this.page = 1,
    this.limit = 20,
    this.sort = 'compatibility',
    this.location,
    this.availability,
    this.experienceMin,
    this.experienceMax,
    this.skills = const [],
    this.contractType,
  });

  final int? offerId;
  final CandidateRecommendationStatus status;
  final double scoreMin;
  final int page;
  final int limit;
  final String sort;
  final String? location;
  final String? availability;
  final double? experienceMin;
  final double? experienceMax;
  final List<String> skills;
  final String? contractType;

  CandidateRecommendationQuery copyWith({
    int? offerId,
    bool clearOffer = false,
    CandidateRecommendationStatus? status,
    double? scoreMin,
    int? page,
    int? limit,
    String? sort,
    String? location,
    String? availability,
    double? experienceMin,
    double? experienceMax,
    List<String>? skills,
    String? contractType,
  }) => CandidateRecommendationQuery(
    offerId: clearOffer ? null : offerId ?? this.offerId,
    status: status ?? this.status,
    scoreMin: (scoreMin ?? this.scoreMin).clamp(0, 100).toDouble(),
    page: (page ?? this.page).clamp(1, 1000000).toInt(),
    limit: (limit ?? this.limit).clamp(1, 100).toInt(),
    sort: sort ?? this.sort,
    location: location ?? this.location,
    availability: availability ?? this.availability,
    experienceMin: experienceMin ?? this.experienceMin,
    experienceMax: experienceMax ?? this.experienceMax,
    skills: skills ?? this.skills,
    contractType: contractType ?? this.contractType,
  );

  Map<String, String?> toQueryParameters() => {
    'offerId': offerId?.toString(),
    'status': status.apiValue,
    'scoreMin': scoreMin > 0 ? scoreMin.toStringAsFixed(0) : null,
    'page': page.toString(),
    'limit': limit.toString(),
    'sort': sort,
    'location': location,
    'availability': availability,
    'experienceMin': experienceMin?.toString(),
    'experienceMax': experienceMax?.toString(),
    'skills': skills.isEmpty ? null : skills.join(','),
    'contractType': contractType,
  };

  String get cacheKey => toQueryParameters().entries
      .where((entry) => entry.value != null)
      .map((entry) => '${entry.key}=${entry.value}')
      .join('&');
}

@immutable
class CandidateRecommendationData {
  const CandidateRecommendationData({
    required this.items,
    required this.offers,
    required this.stats,
    required this.page,
    required this.totalPages,
    required this.totalItems,
    required this.selectedOfferId,
  });

  final List<RecruiterCandidateRecommendation> items;
  final List<RecruiterCandidateOffer> offers;
  final CandidateRecommendationStats stats;
  final int page;
  final int totalPages;
  final int totalItems;
  final int? selectedOfferId;
}
