import 'dart:typed_data';

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
  String? _photoUrl;
  StudentProfile? _lastProfile;

  @override
  Future<StudentProfile> fetchProfile() async {
    try {
      return _lastProfile = _map(
        await api.getJson('/api/v1/candidates/profile'),
      );
    } on ApiException catch (error) {
      throw ProfileException(
        'Profil indisponible (${error.statusCode ?? 'réseau'}).',
      );
    }
  }

  @override
  Future<StudentProfile> saveProfile(StudentProfile profile) async {
    if (_serverHasCv && profile.cv == null) {
      throw const ProfileException(
        'La suppression du CV n’est pas disponible. Vous pouvez le remplacer.',
      );
    }
    if (profile.projects.isNotEmpty ||
        profile.recommendations.isNotEmpty ||
        profile.visibility.hiddenFromCurrentEmployer) {
      throw const ProfileException(
        'Certaines sections (projets, photo, recommandations, masquage employeur) ne sont pas enregistrables via cette API.',
      );
    }
    if (profile.cv?.bytes != null &&
        !profile.cv!.fileName.toLowerCase().endsWith('.pdf')) {
      throw const ProfileException('Le serveur accepte uniquement les CV PDF.');
    }
    for (final experience in profile.experiences) {
      if (experience.period.trim().isNotEmpty &&
          !_isIsoPeriod(experience.period)) {
        throw const ProfileException(
          'Pour enregistrer une expérience, utilisez une période au format AAAA-MM-JJ – AAAA-MM-JJ.',
        );
      }
    }
    final payload = <String, Object?>{
      'first_name': profile.firstName.trim(),
      'last_name': profile.lastName.trim(),
      'headline': profile.headline.trim(),
      'bio': profile.bio.trim(),
      'location': profile.city.trim(),
      if (profile.phone != _lastProfile?.phone)
        'phone': profile.phone.trim().replaceAll(RegExp(r'\s+'), ''),
      if (profile.address != _lastProfile?.address)
        'address': profile.address.trim(),
      'skills': profile.skills
          .map((skill) => skill.name.trim())
          .where((name) => name.isNotEmpty)
          .toList(),
      'links': {
        'github': _url(profile.links.github),
        'linkedin': _url(profile.links.linkedin),
        'portfolio': _url(profile.links.portfolio),
      },
      'visibility': {
        'visible_to_recruiters': profile.visibility.visibleToRecruiters,
      },
      'alternance': {
        'rhythm_type': profile.availability.rhythm,
        if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(profile.availability.start))
          'available_from': profile.availability.start,
        'contract_duration_months': profile.availability.durationMonths,
      },
      'experiences': [
        for (final item in profile.experiences)
          {
            'title': item.title,
            'organization': item.organization,
            'description': item.description,
            if (_isoDates(item.period).isNotEmpty)
              'start_date': _isoDates(item.period).first,
            if (_isoDates(item.period).length > 1)
              'end_date': _isoDates(item.period)[1],
          },
      ],
      'educations': [
        for (final item in profile.educations)
          {
            'school_name': item.school,
            'field_of_study': item.title,
            'degree': _degree(item.title),
            if (_years(item.period).isNotEmpty)
              'start_year': _years(item.period).first,
            if (_years(item.period).length > 1)
              'end_year': _years(item.period)[1],
          },
      ],
    };
    // A photo/name edit must not rewrite degrees or dates that this form does not model.
    if (identical(profile.educations, _lastProfile?.educations)) {
      payload.remove('educations');
    }
    if (identical(profile.experiences, _lastProfile?.experiences)) {
      payload.remove('experiences');
    }
    if (identical(profile.skills, _lastProfile?.skills)) {
      payload.remove('skills');
    }
    // Avoid null fields that Spring treats as explicit clears/invalid values.
    (payload['alternance'] as Map).removeWhere(
      (key, value) => value == null || value == '',
    );
    if ((payload['alternance'] as Map).isEmpty) payload.remove('alternance');
    try {
      await api.patchJson('/api/v1/candidates/profile', body: payload);
      if (profile.photo != null && profile.photo!.url == null) {
        await api.sendMultipart(
          'PUT',
          '/api/v1/users/profile-picture',
          fileField: 'file',
          fileBytes: profile.photo!.bytes,
          fileName: profile.photo!.fileName,
        );
      } else if (profile.photo == null && _photoUrl != null) {
        await api.deleteJson('/api/v1/users/profile-picture');
      }
      if (profile.cv?.bytes != null) {
        await api.sendMultipart(
          'PUT',
          '/api/v1/candidates/profile/resume',
          fileBytes: profile.cv!.bytes,
          fileName: profile.cv!.fileName,
        );
      }
      return await fetchProfile();
    } on ApiException catch (error) {
      throw ProfileException(
        'Enregistrement incomplet ou refusé (${error.statusCode ?? 'réseau'}). Actualisez le profil pour vérifier les champs enregistrés avant de réessayer.',
      );
    }
  }

  static String _degree(String name) {
    final lowered = name.toLowerCase();
    if (lowered.contains('master') || lowered.contains('mastère')) {
      return 'MASTERS';
    }
    if (lowered.contains('doctor') || lowered.contains('phd')) {
      return 'DOCTORATE';
    }
    if (lowered.contains('ingénieur') || lowered.contains('engineer')) {
      return 'ENGINEERING';
    }
    if (lowered.contains('licence') || lowered.contains('bachelor')) {
      return 'BACHELORS';
    }
    return 'OTHER';
  }

  static List<String> _isoDates(String raw) =>
      RegExp(r'\d{4}-\d{2}-\d{2}')
          .allMatches(raw)
          .map((match) => match.group(0)!)
          .toList();
  static bool _isIsoPeriod(String raw) =>
      _isoDates(raw).isNotEmpty && raw.trim().startsWith(_isoDates(raw).first);
  static List<int> _years(String raw) =>
      RegExp(r'\b(?:19|20)\d{2}\b')
          .allMatches(raw)
          .map((match) => int.parse(match.group(0)!))
          .toList();

  static String? _url(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    final full = value.contains('://') ? value : 'https://$value';
    return Uri.tryParse(full)?.hasAuthority == true ? full : null;
  }

  StudentProfile _map(Object? raw) {
    final j = Map<String, dynamic>.from(raw as Map);
    _serverHasCv = j['cv_url'] != null;
    _photoUrl = (j['profile_picture_url'] ?? j['photo_url'])?.toString();
    final links = _object(j['links']);
    final alt = _object(j['alternance']);
    final visibility = _object(j['visibility']);
    final education = j['educations'] as List? ?? const [];
    final experience = j['experiences'] as List? ?? const [];
    final skills = j['skills'] as List? ?? const [];
    return StudentProfile(
      photo: _photoUrl == null
          ? null
          : ProfilePhoto(
              bytes: Uint8List(0),
              fileName: 'Photo enregistrée',
              url: _photoUrl,
            ),
      firstName: '${j['first_name'] ?? ''}',
      lastName: '${j['last_name'] ?? ''}',
      email: '${j['email'] ?? ''}',
      phone: '${j['phone'] ?? ''}',
      address: '${j['address'] ?? ''}',
      headline: '${j['headline'] ?? ''}',
      city: '${j['location'] ?? ''}',
      bio: '${j['bio'] ?? ''}',
      links: ProfileLinks(
        github: '${links['github'] ?? ''}',
        linkedin: '${links['linkedin'] ?? ''}',
        portfolio: '${links['portfolio'] ?? ''}',
      ),
      skills: [
        for (final skill in skills)
          ProfileSkill('$skill', ProfileSkillLevel.intermediate),
      ],
      educations: [
        for (final raw in education)
          ProfileEducation(
            title: '${(raw as Map)['field_of_study'] ?? raw['degree'] ?? ''}',
            school: '${raw['school_name'] ?? ''}',
            period: [
              raw['start_year'],
              raw['end_year'],
            ].where((item) => item != null).join(' – '),
          ),
      ],
      experiences: [
        for (final raw in experience)
          ProfileExperience(
            title: '${(raw as Map)['title'] ?? ''}',
            organization: '${raw['organization'] ?? ''}',
            description: '${raw['description'] ?? ''}',
            period: [
              raw['start_date'],
              raw['end_date'],
            ].where((item) => item != null).join(' – '),
          ),
      ],
      cv: j['cv_url'] == null
          ? null
          : const ProfileCv(fileName: 'CV enregistré'),
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
