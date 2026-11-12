import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/company_verification.dart';
import 'verification_repository.dart';

/// Implémentation de [VerificationRepository] branchée sur l'API.
class ApiVerificationRepository implements VerificationRepository {
  ApiVerificationRepository(this._api);

  final ApiClient _api;

  static const String _basePath = '/api/v1/admin/verifications';

  @override
  Future<List<CompanyVerification>> fetchVerifications({
    required VerificationFilter filter,
    String search = '',
  }) => _guard(() async {
    final json = await _api.getJson(
      _basePath,
      query: {'status': filter.apiValue, 'search': search.trim()},
    );
    final items = switch (json) {
      final List<Object?> list => list,
      final Map<String, dynamic> map =>
        map['items'] as List<Object?>? ?? const [],
      _ => const <Object?>[],
    };
    return items.map((item) => _verification(_object(item))).toList();
  });

  @override
  Future<CompanyVerification> retryAutomatic(String id) => _guard(() async {
    final json = await _api.postJson('$_basePath/$id/retry', body: const {});
    return _verification(_object(json));
  });

  @override
  Future<CompanyVerification> decide(
    String id,
    VerificationDecision decision, {
    String note = '',
  }) => _guard(() async {
    final json = await _api.postJson(
      '$_basePath/$id/decision',
      body: {'decision': decision.apiValue, 'note': note.trim()},
    );
    return _verification(_object(json));
  });

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException catch (error) {
      throw VerificationException(switch (error.statusCode) {
        401 => 'Ta session a expiré. Reconnecte-toi.',
        403 => 'Accès refusé : cette page est réservée aux administrateurs.',
        404 => 'Cette demande n’existe plus.',
        422 => 'Certaines informations sont invalides.',
        _ => 'Le serveur ne répond pas. Réessaie dans un instant.',
      }, statusCode: error.statusCode);
    }
  }

  Map<String, Object?> _object(Object? value) {
    if (value case final Map<String, dynamic> map) return map;
    if (value case final Map<Object?, Object?> map) {
      return map.map((key, value) => MapEntry('$key', value));
    }
    throw const VerificationException('Réponse inattendue du serveur.');
  }

  CompanyVerification _verification(Map<String, Object?> json) {
    final recruiter = json['recruiter'] == null
        ? null
        : _object(json['recruiter']);
    final registry = json['registry'] == null
        ? null
        : _object(json['registry']);
    return CompanyVerification(
      id: '${json['id']}',
      companyId: '${json['companyId']}',
      companyName: json['companyName'] as String? ?? '',
      siret: json['siret'] as String? ?? '',
      city: json['city'] as String? ?? '',
      declaredAddress: json['address'] as String? ?? '',
      submittedAt:
          DateTime.tryParse(json['submittedAt'] as String? ?? '') ??
          DateTime.now(),
      status: VerificationStatus.fromApi(json['status'] as String?),
      issue: VerificationIssue.values.firstWhere(
        (issue) => issue.name == json['issue'],
        orElse: () => VerificationIssue.none,
      ),
      registryName: registry?['name'] as String?,
      registryAddress: registry?['address'] as String?,
      recruiterName: recruiter?['name'] as String?,
      recruiterEmail: recruiter?['email'] as String?,
      apiMessage: json['apiMessage'] as String?,
      checks: (json['checks'] as List<Object?>? ?? const [])
          .map(_object)
          .map(
            (check) => VerificationCheck(
              label: check['label'] as String? ?? '',
              detail: check['detail'] as String? ?? '',
              outcome: CheckOutcome.values.firstWhere(
                (outcome) => outcome.name == check['outcome'],
                orElse: () => CheckOutcome.unavailable,
              ),
            ),
          )
          .toList(),
      history: (json['history'] as List<Object?>? ?? const [])
          .map(_object)
          .map(
            (event) => VerificationEvent(
              label: event['label'] as String? ?? '',
              date:
                  DateTime.tryParse(event['date'] as String? ?? '') ??
                  DateTime.now(),
              author: event['author'] as String? ?? '',
              note: event['note'] as String? ?? '',
            ),
          )
          .toList(),
    );
  }
}
