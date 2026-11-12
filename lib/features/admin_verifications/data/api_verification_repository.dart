import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/company_verification.dart';
import 'verification_repository.dart';

/// Reuses the company verification status list; no generic /verifications API.
class ApiVerificationRepository implements VerificationRepository {
  ApiVerificationRepository(this.api);
  final ApiClient api;

  @override
  Future<List<CompanyVerification>> fetchVerifications({
    required VerificationFilter filter,
    String search = '',
  }) async {
    try {
      final items = <CompanyVerification>[];
      for (var page = 1; page <= 20; page++) {
        final body = Map<String, dynamic>.from(
          await api.getJson(
            '/api/v1/admin/companies',
            query: {
              'page': '$page',
              'limit': '100',
              if (search.trim().isNotEmpty) 'search': search.trim(),
            },
          ) as Map,
        );
        final data = body['data'] as List? ?? const [];
        for (final value in data) {
          final company = Map<String, dynamic>.from(value as Map);
          final status = '${company['verification_status'] ?? ''}'
              .toUpperCase();
          final converted = switch (status) {
            'VERIFIED' => VerificationStatus.verifiedManual,
            'REJECTED' => VerificationStatus.refused,
            _ => VerificationStatus.toReview,
          };
          items.add(
            CompanyVerification(
              id: '${company['id']}',
              companyId: '${company['id']}',
              companyName: '${company['name'] ?? ''}',
              siret: '${company['siret'] ?? ''}',
              city: '',
              submittedAt:
                  DateTime.tryParse('${company['created_at']}') ??
                  DateTime.fromMillisecondsSinceEpoch(0),
              status: converted,
              issue: VerificationIssue.none,
            ),
          );
        }
        final pagination = Map<String, dynamic>.from(
          body['pagination'] as Map? ?? {},
        );
        if (page >= (pagination['total_pages'] as num? ?? 1).toInt() ||
            data.isEmpty) {
          break;
        }
      }
      return items.where((item) => filter.matches(item.status)).toList();
    } on ApiException catch (error) {
      throw VerificationException(
        'Vérifications indisponibles (${error.statusCode ?? 'réseau'}).',
        statusCode: error.statusCode,
      );
    }
  }

  @override
  Future<CompanyVerification> retryAutomatic(String id) async =>
      throw const VerificationException(
        'Vérification automatique non exposée par cette API.',
      );

  @override
  Future<CompanyVerification> decide(
    String id,
    VerificationDecision decision, {
    String note = '',
  }) async => throw const VerificationException(
    'Utilisez la validation d’entreprise dans l’administration.',
  );
}
