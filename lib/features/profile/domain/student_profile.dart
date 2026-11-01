import 'package:flutter/foundation.dart';

/// Niveau déclaré sur une compétence.
enum ProfileSkillLevel {
  beginner('Débutant'),
  intermediate('Intermédiaire'),
  advanced('Avancé');

  const ProfileSkillLevel(this.label);

  final String label;

  /// Niveau suivant, en boucle (Débutant → Intermédiaire → Avancé → Débutant).
  ProfileSkillLevel get next =>
      ProfileSkillLevel.values[(index + 1) % ProfileSkillLevel.values.length];
}

@immutable
class ProfileSkill {
  const ProfileSkill(this.name, this.level);

  final String name;
  final ProfileSkillLevel level;

  ProfileSkill withLevel(ProfileSkillLevel level) => ProfileSkill(name, level);
}

/// Une formation : « Master Informatique · M1 », « Université Paris Cité ».
@immutable
class ProfileEducation {
  const ProfileEducation({
    required this.title,
    required this.school,
    this.period = '',
  });

  final String title;
  final String school;

  /// Période libre : « 2026 – 2028 · alternance en M2 ».
  final String period;
}

/// Une expérience : stage, emploi, tutorat…
@immutable
class ProfileExperience {
  const ProfileExperience({
    required this.title,
    required this.organization,
    this.period = '',
    this.description = '',
  });

  final String title;
  final String organization;
  final String period;
  final String description;
}

/// Un projet personnel ou étudiant.
@immutable
class ProfileProject {
  const ProfileProject({
    required this.title,
    required this.description,
    this.tags = const [],
  });

  final String title;
  final String description;
  final List<String> tags;
}

@immutable
class ProfileLinks {
  const ProfileLinks({
    this.github = '',
    this.linkedin = '',
    this.portfolio = '',
  });

  final String github;
  final String linkedin;
  final String portfolio;

  bool get isEmpty =>
      github.trim().isEmpty &&
      linkedin.trim().isEmpty &&
      portfolio.trim().isEmpty;

  ProfileLinks copyWith({String? github, String? linkedin, String? portfolio}) {
    return ProfileLinks(
      github: github ?? this.github,
      linkedin: linkedin ?? this.linkedin,
      portfolio: portfolio ?? this.portfolio,
    );
  }
}

/// Photo de profil choisie par l'étudiant·e.
@immutable
class ProfilePhoto {
  const ProfilePhoto({required this.bytes, required this.fileName});

  /// Contenu de l'image (JPG, PNG ou WebP).
  final Uint8List bytes;
  final String fileName;
}

@immutable
class ProfileCv {
  const ProfileCv({required this.fileName, this.updatedLabel = ''});

  final String fileName;

  /// Date déjà mise en forme : « Mis à jour il y a 3 jours ».
  final String updatedLabel;
}

@immutable
class ProfileAvailability {
  const ProfileAvailability({
    this.start = '',
    this.durationMonths,
    this.rhythm,
    this.maxCommuteMinutes = 45,
  });

  /// « Septembre 2027 », « Dès que possible »…
  final String start;
  final int? durationMonths;

  /// « 3 sem / 1 sem »…
  final String? rhythm;
  final int maxCommuteMinutes;

  ProfileAvailability copyWith({
    String? start,
    int? durationMonths,
    String? rhythm,
    int? maxCommuteMinutes,
  }) {
    return ProfileAvailability(
      start: start ?? this.start,
      durationMonths: durationMonths ?? this.durationMonths,
      rhythm: rhythm ?? this.rhythm,
      maxCommuteMinutes: maxCommuteMinutes ?? this.maxCommuteMinutes,
    );
  }
}

@immutable
class ProfileVisibility {
  const ProfileVisibility({
    this.visibleToRecruiters = true,
    this.hiddenFromCurrentEmployer = false,
    this.openToReplacement = true,
  });

  /// Sinon, seules les entreprises avec qui l'étudiant·e matche le voient.
  final bool visibleToRecruiters;
  final bool hiddenFromCurrentEmployer;

  /// Ouvert·e aux propositions « Remplace-moi ».
  final bool openToReplacement;

  ProfileVisibility copyWith({
    bool? visibleToRecruiters,
    bool? hiddenFromCurrentEmployer,
    bool? openToReplacement,
  }) {
    return ProfileVisibility(
      visibleToRecruiters: visibleToRecruiters ?? this.visibleToRecruiters,
      hiddenFromCurrentEmployer:
          hiddenFromCurrentEmployer ?? this.hiddenFromCurrentEmployer,
      openToReplacement: openToReplacement ?? this.openToReplacement,
    );
  }
}

/// Recommandation reçue d'un·e ancien·ne ou d'un·e tuteur·rice.
@immutable
class ProfileRecommendation {
  const ProfileRecommendation({
    required this.quote,
    required this.author,
    this.context = '',
  });

  final String quote;
  final String author;

  /// « ancienne du master, dév chez … ».
  final String context;
}

/// Profil complet d'un·e étudiant·e, tel qu'il le voit et le modifie.
@immutable
class StudentProfile {
  const StudentProfile({
    this.firstName = '',
    this.lastName = '',
    this.photo,
    this.headline = '',
    this.city = '',
    this.email = '',
    this.bio = '',
    this.educations = const [],
    this.experiences = const [],
    this.projects = const [],
    this.skills = const [],
    this.links = const ProfileLinks(),
    this.cv,
    this.availability = const ProfileAvailability(),
    this.visibility = const ProfileVisibility(),
    this.recommendations = const [],
  });

  static const int headlineMaxLength = 80;
  static const int bioMaxLength = 400;

  final String firstName;
  final String lastName;

  /// Photo de profil, `null` tant qu'aucune n'a été ajoutée.
  final ProfilePhoto? photo;

  /// Première ligne vue par les recruteurs (80 caractères max).
  final String headline;
  final String city;
  final String email;

  /// Présentation libre (400 caractères max).
  final String bio;
  final List<ProfileEducation> educations;
  final List<ProfileExperience> experiences;
  final List<ProfileProject> projects;
  final List<ProfileSkill> skills;
  final ProfileLinks links;
  final ProfileCv? cv;
  final ProfileAvailability availability;
  final ProfileVisibility visibility;
  final List<ProfileRecommendation> recommendations;

  /// « Ariel Benatsi ».
  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  /// Nom affiché sur le profil, nom de famille d'abord : « Benatsi Ariel ».
  String get displayName => '${lastName.trim()} ${firstName.trim()}'.trim();

  /// Initiales pour l'avatar, nom de famille d'abord (« BA »), « ? » si aucun
  /// nom. Même convention que le dashboard.
  String get initials {
    final first = firstName.trim();
    final last = lastName.trim();
    final value =
        '${last.isEmpty ? '' : last[0]}${first.isEmpty ? '' : first[0]}';
    return value.isEmpty ? '?' : value.toUpperCase();
  }

  /// Compétences triées du plus haut niveau au plus bas.
  List<ProfileSkill> get skillsByLevel =>
      [...skills]..sort((a, b) => b.level.index.compareTo(a.level.index));

  /// [clearPhoto] retire la photo (un `null` ne suffit pas à l'effacer).
  StudentProfile copyWith({
    String? firstName,
    String? lastName,
    ProfilePhoto? photo,
    bool clearPhoto = false,
    String? headline,
    String? city,
    String? email,
    String? bio,
    List<ProfileEducation>? educations,
    List<ProfileExperience>? experiences,
    List<ProfileProject>? projects,
    List<ProfileSkill>? skills,
    ProfileLinks? links,
    ProfileCv? cv,
    ProfileAvailability? availability,
    ProfileVisibility? visibility,
    List<ProfileRecommendation>? recommendations,
  }) {
    return StudentProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photo: clearPhoto ? null : photo ?? this.photo,
      headline: headline ?? this.headline,
      city: city ?? this.city,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      educations: educations ?? this.educations,
      experiences: experiences ?? this.experiences,
      projects: projects ?? this.projects,
      skills: skills ?? this.skills,
      links: links ?? this.links,
      cv: cv ?? this.cv,
      availability: availability ?? this.availability,
      visibility: visibility ?? this.visibility,
      recommendations: recommendations ?? this.recommendations,
    );
  }
}
