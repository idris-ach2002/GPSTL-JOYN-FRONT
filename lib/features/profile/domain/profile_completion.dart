import 'profile_options.dart';
import 'student_profile.dart';

/// Sections du profil, dans l'ordre de l'écran de modification.
enum ProfileSection {
  identity('Identité'),
  presentation('Présentation'),
  education('Formation'),
  experiences('Expériences'),
  skills('Compétences'),
  links('Liens et CV'),
  availability('Disponibilité'),
  visibility('Visibilité');

  const ProfileSection(this.label);

  final String label;
}

/// Taux de complétion du profil et sections à compléter.
class ProfileCompletion {
  ProfileCompletion._(this._done);

  factory ProfileCompletion.of(StudentProfile profile) {
    bool filled(String value) => value.trim().isNotEmpty;

    final done = <ProfileSection, bool>{
      ProfileSection.identity:
          filled(profile.firstName) &&
          filled(profile.lastName) &&
          filled(profile.headline),
      ProfileSection.presentation:
          profile.bio.trim().length >= ProfileOptions.minBioLength,
      ProfileSection.education: profile.educations.isNotEmpty,
      ProfileSection.experiences: profile.experiences.isNotEmpty,
      ProfileSection.skills: profile.skills.length >= ProfileOptions.minSkills,
      ProfileSection.links: !profile.links.isEmpty || profile.cv != null,
      ProfileSection.availability:
          filled(profile.availability.start) &&
          profile.availability.rhythm != null,
      ProfileSection.visibility: true,
    };
    return ProfileCompletion._(done);
  }

  final Map<ProfileSection, bool> _done;

  bool isComplete(ProfileSection section) => _done[section] ?? false;

  List<ProfileSection> get missing => [
    for (final section in ProfileSection.values)
      if (!isComplete(section)) section,
  ];

  /// Pourcentage de sections complètes, de 0 à 100.
  int get percent {
    final total = ProfileSection.values.length;
    final complete = total - missing.length;
    return (complete * 100 / total).round();
  }

  /// Conseil affiché sous le pourcentage.
  String get tip => missing.isEmpty
      ? 'Ton profil est complet. Bravo !'
      : 'À compléter : ${missing.map((s) => s.label).join(', ')}.';
}
