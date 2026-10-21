import 'cv_document.dart';
import 'experience.dart';
import 'skill_comparison.dart';

/// Profil d'un candidat tel qu'affiché sur le dashboard recruteur.
///
/// Tous les champs sont optionnels : tant que le backend n'est pas branché,
/// ils valent `null` et l'interface affiche un tiret à la place.
/// C'est à l'implémentation de `DashboardRepository` de convertir la réponse
/// de l'API en [CandidateProfile].
class CandidateProfile {
  const CandidateProfile({
    this.firstName,
    this.lastName,
    this.headline,
    this.school,
    this.location,
    this.matchScore,
    this.matchLabel,
    this.ranking,
    this.matchHighlights,
    this.offerTitle,
    this.skills,
    this.experiences,
    this.cv,
  });

  final String? firstName;
  final String? lastName;

  /// Accroche (ex. « Développeuse Full-Stack en devenir »).
  final String? headline;
  final String? school;
  final String? location;

  /// Score d'adéquation avec l'offre, de 0 à 100.
  final int? matchScore;

  /// Appréciation du score (ex. « Très forte adéquation »).
  final String? matchLabel;

  /// Classement parmi les candidats (ex. « Top 3 de vos 28 candidats »).
  final String? ranking;

  /// Points forts du match (rythme, distance, stack…).
  final List<String>? matchHighlights;

  /// Offre à laquelle le candidat est comparé.
  final String? offerTitle;
  final List<SkillComparison>? skills;
  final List<Experience>? experiences;
  final CvDocument? cv;

  /// Prénom et nom, ou `null` si aucun des deux n'est connu.
  String? get fullName {
    final parts = [
      firstName,
      lastName,
    ].whereType<String>().where((part) => part.trim().isNotEmpty);
    return parts.isEmpty ? null : parts.join(' ');
  }

  /// Initiales pour l'avatar (ex. « BA »), ou `null`.
  String? get initials {
    final letters = [lastName, firstName]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part.trim()[0].toUpperCase());
    return letters.isEmpty ? null : letters.join();
  }
}
