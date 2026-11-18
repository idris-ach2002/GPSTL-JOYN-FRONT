import '../../../core/network/api_client.dart';
import '../domain/student_profile_draft.dart';
import 'profile_repository.dart';

/// Sauvegarde uniquement les champs acceptés par CandidateProfilePatch.
class ApiOnboardingRepository implements ProfileRepository {
  ApiOnboardingRepository(this.api);
  final ApiClient api;
  static String? _date(String period, int index) {
    final dates = RegExp(r'\d{4}-\d{2}(?:-\d{2})?')
        .allMatches(period)
        .map((m) => m.group(0)!)
        .toList();
    if (dates.length <= index) return null;
    return dates[index].length == 7 ? '${dates[index]}-01' : dates[index];
  }

  @override
  Future<void> saveProfile(StudentProfileDraft p) async {
    final contract = switch (p.searchKind) {
      'Un stage' => 'INTERNSHIP',
      'Un CDI' => 'CDI',
      'Un CDD' => 'CDD',
      'Une mission freelance' => 'FREELANCE',
      _ => 'APPRENTICESHIP',
    };
    await api.patchJson(
      '/api/v1/candidates/profile',
      body: {
        if (p.city.isNotEmpty) 'location': p.city,
        'skills': p.skills.keys.toList(),
        if (p.cv?.experiences.isNotEmpty == true)
          'experiences': [
            for (final e in p.cv!.experiences)
              if (e.title.trim().isNotEmpty)
                {
                  'title': e.title,
                  'organization': e.company,
                  if (_date(e.period, 0) != null)
                    'start_date': _date(e.period, 0),
                  if (_date(e.period, 1) != null)
                    'end_date': _date(e.period, 1),
                },
          ],
        'preferences': {
          'contract_types': [contract],
          if (p.remoteMode != null)
            'remote_policy': switch (p.remoteMode) {
              'Sur site' => 'ONSITE',
              'Hybride' => 'HYBRID',
              'Full remote' => 'REMOTE',
              _ => null,
            },
          if (p.desiredMonthlySalary != null)
            'min_salary': p.desiredMonthlySalary,
        },
        if (p.rhythm != null) 'alternance': {'rhythm_type': p.rhythm},
        if (p.school.isNotEmpty && p.degreeTitle.isNotEmpty)
          'educations': [
            {
              'school_name': p.school,
              'field_of_study': p.degreeTitle,
              'degree': switch (p.level) {
                'Bac+3' => 'BACHELORS',
                'Bac+4' || 'Bac+5' => 'MASTERS',
                'Doctorat' => 'DOCTORATE',
                _ => 'OTHER',
              },
              if (p.graduationYear != null) 'end_year': p.graduationYear,
            },
          ],
      },
    );
  }
}
