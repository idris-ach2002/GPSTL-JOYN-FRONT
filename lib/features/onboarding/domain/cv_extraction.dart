import 'package:flutter/foundation.dart';

/// Fichier de CV choisi par l'étudiant·e.
@immutable
class PickedCv {
  const PickedCv({required this.name, required this.sizeInBytes});

  final String name;
  final int sizeInBytes;

  /// Taille lisible : « 212 Ko ».
  String get readableSize {
    final kilobytes = (sizeInBytes / 1024).round();
    if (kilobytes < 1024) return '$kilobytes Ko';
    return '${(kilobytes / 1024).toStringAsFixed(1)} Mo';
  }

  /// Extension en majuscules : « PDF », « DOCX ».
  String get extension {
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1).toUpperCase();
  }
}

/// Une formation lue dans le CV.
@immutable
class CvEducation {
  const CvEducation({
    required this.title,
    required this.school,
    required this.period,
  });

  final String title;
  final String school;
  final String period;
}

/// Une expérience lue dans le CV.
@immutable
class CvExperience {
  const CvExperience({
    required this.title,
    required this.company,
    required this.period,
    required this.summary,
  });

  final String title;
  final String company;
  final String period;
  final String summary;
}

/// Résultat de l'analyse d'un CV.
@immutable
class CvExtraction {
  const CvExtraction({
    required this.fullName,
    required this.email,
    required this.city,
    required this.educations,
    required this.experiences,
    required this.skills,
    required this.languages,
    this.isSample = false,
  });

  final String fullName;
  final String email;
  final String city;
  final List<CvEducation> educations;
  final List<CvExperience> experiences;
  final List<String> skills;

  /// Langues telles que lues : « Français (natif) · Anglais (B2) ».
  final String languages;

  /// `true` quand les données sont un exemple et non le contenu réel du CV
  /// (analyse simulée, en attendant l'API).
  final bool isSample;

  /// Nombre d'éléments extraits, affiché dans la carte du fichier :
  /// identité (3) + formations + expériences + compétences + langues.
  int get extractedCount =>
      3 +
      educations.length +
      experiences.length +
      skills.length +
      (languages.isEmpty ? 0 : languages.split('·').length);

  CvExtraction copyWith({
    String? fullName,
    String? email,
    String? city,
    List<String>? skills,
  }) {
    return CvExtraction(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      city: city ?? this.city,
      educations: educations,
      experiences: experiences,
      skills: skills ?? this.skills,
      languages: languages,
      isSample: isSample,
    );
  }
}
