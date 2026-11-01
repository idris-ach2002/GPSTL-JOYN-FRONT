import '../domain/job_offer.dart';
import '../domain/job_offer_draft.dart';

/// Contrat JSON déjà aligné sur le POST Spring Boot actuel.
///
/// La sélection d'entreprise reste volontairement hors payload : le backend
/// actuel déduit encore l'entreprise du profil recruteur. La feature garde
/// pourtant `companyId` dans son domaine afin d'être prête quand le backend
/// acceptera le choix d'une entreprise de la base.
abstract final class JobOfferApiMapper {
  static const String createPath = '/api/v1/recruiters/jobs';

  static String jobPath(int id) => '/api/v1/jobs/$id';

  static Map<String, Object?> toCreateJson(
    JobOfferDraft draft,
    JobOfferStatus status,
  ) {
    final json = <String, Object?>{
      'title': draft.title,
      'contract_type': draft.contractType.apiValue,
      'location': draft.location,
      'remote_policy': draft.remoteMode.apiValue,
      'experience_level': draft.experienceLevel.apiValue,
      'description': draft.description,
      'salary_min': draft.salaryMin,
      'salary_max': draft.salaryMax,
      'currency': draft.currency,
      'salary_period': draft.salaryPeriod.apiValue,
      'skills': draft.skills,
      'status': status.apiValue,
    };

    if (draft.contractType.isWorkStudy) {
      json.addAll({
        'rhythm_type': draft.rhythmType,
        'start_date': _date(draft.startDate),
        'duration_months': draft.durationMonths,
        'degree_level_required': draft.degreeLevelRequired,
      });
    }

    return json;
  }

  static String? _date(DateTime? date) {
    if (date == null) return null;
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}
