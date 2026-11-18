import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/company_verification.dart';
import 'verification_repository.dart';

class ApiVerificationRepository implements VerificationRepository {
  ApiVerificationRepository(this.api);
  final ApiClient api;
  static const path = '/api/v1/admin/verifications';

  @override
  Future<List<CompanyVerification>> fetchVerifications({
    required VerificationFilter filter,
    String search = '',
  }) async {
    try {
      final items = <CompanyVerification>[];
      for (var page = 1; ; page++) {
        final rows = await api.getJson(
          path,
          query: {'page': '$page', 'search': search.trim()},
        ) as List;
        items.addAll(
          rows.map(_item).where((item) => filter.matches(item.status)),
        );
        if (rows.length < 100) return items;
      }
    } on ApiException catch (error) {
      throw _exception(error);
    }
  }

  @override
  Future<CompanyVerification> retryAutomatic(String id) =>
      _write('$path/$id/retry');

  @override
  Future<CompanyVerification> decide(
    String id,
    VerificationDecision decision, {
    String note = '',
  }) => _write(
    '$path/$id/decision',
    body: {'decision': decision.apiValue, 'note': note},
  );

  Future<CompanyVerification> attachDocument(
    String id,
    String name,
    Uint8List bytes,
    String note,
  ) async {
    try {
      return _item(
        await api.sendMultipart(
          'POST',
          '$path/$id/document',
          fileBytes: bytes,
          fileName: name,
          fileField: 'evidence',
          fields: {'note': note},
        ),
      );
    } on ApiException catch (error) {
      throw _exception(error);
    }
  }

  Future<CompanyVerification> _write(String path, {Object? body}) async {
    try {
      return _item(await api.postJson(path, body: body));
    } on ApiException catch (error) {
      throw _exception(error);
    }
  }

  VerificationException _exception(ApiException error) =>
      VerificationException(switch (error.statusCode) {
        404 || 422 => 'Le registre ou la fiche n’a pas confirmé ces informations. Vérifiez le SIRET ou procédez à un contrôle manuel.',
        503 => 'Le registre est indisponible. Vous pouvez traiter le dossier manuellement.',
        400 => 'Vérifiez le contenu de la demande ou du justificatif.',
        _ => 'Vérification indisponible (${error.statusCode ?? 'réseau'}).',
      }, statusCode: error.statusCode);

  CompanyVerification _item(Object? raw) {
    final company = raw as Map;
    final method = company['method'];
    final status = switch ((company['verification_status'], method)) {
      ('VERIFIED', 'REGISTRY') => VerificationStatus.verifiedAuto,
      ('VERIFIED', 'DOCUMENT' || 'MANUAL') => VerificationStatus.verifiedManual,
      ('VERIFIED', _) => VerificationStatus.verifiedAuto,
      ('REJECTED', _) => VerificationStatus.refused,
      ('NOT_VERIFIED', 'REQUEST') => VerificationStatus.documentRequested,
      _ => VerificationStatus.toReview,
    };
    final review = DateTime.tryParse('${company['reviewed_at']}');
    return CompanyVerification(
      id: '${company['id']}',
      companyId: '${company['id']}',
      companyName: '${company['name']}',
      siret: '${company['siret'] ?? ''}',
      city: '',
      declaredAddress: '${company['address'] ?? ''}',
      submittedAt: DateTime.parse('${company['created_at']}'),
      status: status,
      issue: VerificationIssue.none,
      hasDocument: company['has_document'] == true,
      history: [
        if (review != null)
          VerificationEvent(
            author: 'Administration',
            date: review,
            note: '${company['note'] ?? ''}',
            label: method == 'DOCUMENT'
                ? 'Validée sur justificatif PDF'
                : status.label,
          ),
      ],
    );
  }
}
