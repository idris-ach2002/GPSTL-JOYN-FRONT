import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/student_profile.dart';
import 'profile_repository.dart';

/// Reads/writes only fields supported by CandidateProfilePatch.
/// Non-existent backend concepts (projects, recommendation letters, skill levels,
/// employer hiding, replacement flag) are never silently sent or persisted.
class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this.api);
  final ApiClient api;
  bool _serverHasCv = false;

  @override
  Future<StudentProfile> fetchProfile() async {
    try {
      return _map(await api.getJson('/api/v1/candidates/profile'));
    } on ApiException catch (error) {
      throw ProfileException('Profil indisponible (${error.statusCode ?? 'réseau'}).');
    }
  }

  @override
  Future<StudentProfile> saveProfile(StudentProfile profile) async {
    if ((profile.cv != null && profile.cv!.fileName != 'CV enregistré') ||
        (_serverHasCv && profile.cv == null)) {
      throw const ProfileException('Le dépôt ou la suppression de CV nécessite la route spécialisée du serveur et ne peut pas être enregistré par le formulaire actuel.');
    }
    if (profile.projects.isNotEmpty || profile.photo != null ||
        profile.recommendations.isNotEmpty ||
        profile.visibility.hiddenFromCurrentEmployer) {
      throw const ProfileException('Certaines sections (projets, photo, recommandations, masquage employeur) ne sont pas enregistrables via cette API.');
    }
    for (final experience in profile.experiences) {
      if (experience.period.trim().isNotEmpty &&
          !_isIsoPeriod(experience.period)) {
        throw const ProfileException('Pour enregistrer une expérience, utilisez une période au format AAAA-MM-JJ – AAAA-MM-JJ.');
      }
    }
    final payload = <String, Object?>{
      'first_name': profile.firstName.trim(),
      'last_name': profile.lastName.trim(),
      'headline': profile.headline.trim(),
      'bio': profile.bio.trim(),
      'location': profile.city.trim(),
      'skills': profile.skills.map((skill) => skill.name.trim()).where((name) => name.isNotEmpty).toList(),
      'links': {
        'github': _url(profile.links.github),
        'linkedin': _url(profile.links.linkedin),
        'portfolio': _url(profile.links.portfolio),
      },
      'visibility': {'visible_to_recruiters': profile.visibility.visibleToRecruiters},
      'alternance': {
        'rhythm_type': profile.availability.rhythm,
        'contract_duration_months': profile.availability.durationMonths,
      },
      'experiences': [for (final item in profile.experiences) {
        'title': item.title,
        'organization': item.organization,
        'description': item.description,
        if (_isoDates(item.period).isNotEmpty)
          'start_date': _isoDates(item.period).first,
        if (_isoDates(item.period).length > 1)
          'end_date': _isoDates(item.period)[1],
      }],
      'educations': [for (final item in profile.educations) {
        'school_name': item.school,
        'field_of_study': item.title,
        'degree': _degree(item.title),
        if (_years(item.period).isNotEmpty)
          'start_year': _years(item.period).first,
        if (_years(item.period).length > 1)
          'end_year': _years(item.period)[1],
      }],
    };
    // Avoid null fields that Spring treats as explicit clears/invalid values.
    (payload['alternance'] as Map).removeWhere((key, value) => value == null || value == '');
    if ((payload['alternance'] as Map).isEmpty) payload.remove('alternance');
    try {
      return _map(await api.patchJson('/api/v1/candidates/profile', body: payload));
    } on ApiException catch (error) {
      throw ProfileException('Le profil n’a pas été enregistré (${error.statusCode ?? 'réseau'}).');
    }
  }

  static String _degree(String name) {
    final lowered = name.toLowerCase();
    if (lowered.contains('master') || lowered.contains('mastère')) return 'MASTERS';
    if (lowered.contains('doctor') || lowered.contains('phd')) return 'DOCTORATE';
    if (lowered.contains('ingénieur') || lowered.contains('engineer')) return 'ENGINEERING';
    if (lowered.contains('licence') || lowered.contains('bachelor')) return 'BACHELORS';
    return 'OTHER';
  }

  static List<String> _isoDates(String raw) => RegExp(r'\d{4}-\d{2}-\d{2}')
      .allMatches(raw).map((match) => match.group(0)!).toList();
  static bool _isIsoPeriod(String raw) =>
      _isoDates(raw).isNotEmpty && raw.trim().startsWith(_isoDates(raw).first);
  static List<int> _years(String raw) => RegExp(r'\b(?:19|20)\d{2}\b')
      .allMatches(raw).map((match) => int.parse(match.group(0)!)).toList();

  static String? _url(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    final full = value.contains('://') ? value : 'https://$value';
    return Uri.tryParse(full)?.hasAuthority == true ? full : null;
  }

  StudentProfile _map(Object? raw) {
    final j = Map<String, dynamic>.from(raw as Map);
    _serverHasCv = j['cv_url'] != null;
    final links = _object(j['links']);
    final alt = _object(j['alternance']);
    final visibility = _object(j['visibility']);
    final education = j['educations'] as List? ?? const [];
    final experience = j['experiences'] as List? ?? const [];
    final skills = j['skills'] as List? ?? const [];
    return StudentProfile(
      firstName: '${j['first_name'] ?? ''}',
      lastName: '${j['last_name'] ?? ''}',
      email: '${j['email'] ?? ''}',
      headline: '${j['headline'] ?? ''}',
      city: '${j['location'] ?? ''}',
      bio: '${j['bio'] ?? ''}',
      links: ProfileLinks(
        github: '${links['github'] ?? ''}',
        linkedin: '${links['linkedin'] ?? ''}',
        portfolio: '${links['portfolio'] ?? ''}',
      ),
      skills: [for (final skill in skills)
        ProfileSkill('$skill', ProfileSkillLevel.intermediate)],
      educations: [for (final raw in education)
        ProfileEducation(
          title: '${(raw as Map)['field_of_study'] ?? raw['degree'] ?? ''}',
          school: '${raw['school_name'] ?? ''}',
          period: [raw['start_year'],raw['end_year']]
              .where((item) => item != null).join(' – '),
        )],
      experiences: [for (final raw in experience)
        ProfileExperience(
          title: '${(raw as Map)['title'] ?? ''}',
          organization: '${raw['organization'] ?? ''}',
          description: '${raw['description'] ?? ''}',
          period: [raw['start_date'],raw['end_date']]
              .where((item) => item != null).join(' – '),
        )],
      cv: j['cv_url'] == null ? null : const ProfileCv(fileName: 'CV enregistré'),
      availability: ProfileAvailability(
        rhythm: alt['rhythm_type']?.toString(),
        durationMonths: (alt['contract_duration_months'] as num?)?.toInt(),
        start: '${alt['available_from'] ?? ''}',
      ),
      visibility: ProfileVisibility(
        visibleToRecruiters: visibility['visible_to_recruiters'] != false,
      ),
    );
  }

  Map<String, dynamic> _object(Object? raw) =>
      raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
}
