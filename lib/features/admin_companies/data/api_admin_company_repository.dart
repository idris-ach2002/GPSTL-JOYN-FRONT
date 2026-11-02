import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/admin_company.dart';
import 'admin_company_repository.dart';

/// Implémentation de [AdminCompanyRepository] branchée sur l'API.
///
/// Format attendu de `GET /api/v1/admin/companies` :
/// `{ "items": [...], "total": 312, "page": 1, "pageSize": 20 }`.
class ApiAdminCompanyRepository implements AdminCompanyRepository {
  ApiAdminCompanyRepository(this._api);

  final ApiClient _api;

  static const String _basePath = '/api/v1/admin/companies';

  @override
  Future<CompanyPage> fetchCompanies(CompanyQuery query) => _guard(() async {
    final json = _object(
      await _api.getJson(
        _basePath,
        query: {
          'page': '${query.page}',
          'pageSize': '${query.pageSize}',
          'search': query.search.trim(),
          'status': query.status.apiValue,
          'sector': query.sector,
          'sort': query.sort.field,
          'order': query.sort.direction,
        },
      ),
    );
    final items = (json['items'] as List<Object?>? ?? const [])
        .map((item) => _company(_object(item)))
        .toList();
    return CompanyPage(
      items: items,
      total: (json['total'] as num?)?.toInt() ?? items.length,
      page: (json['page'] as num?)?.toInt() ?? query.page,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? query.pageSize,
    );
  });

  @override
  Future<AdminCompany> createCompany(CompanyDraft draft) => _guard(() async {
    final json = await _api.postJson(
      _basePath,
      body: {..._draftBody(draft), 'status': draft.initialStatus.apiValue},
    );
    return _company(_object(json));
  });

  @override
  Future<AdminCompany> updateCompany(String id, CompanyDraft draft) =>
      _guard(() async {
        final json = await _api.patchJson(
          '$_basePath/$id',
          body: _draftBody(draft),
        );
        return _company(_object(json));
      });

  @override
  Future<AdminCompany> updateStatus(
    String id,
    CompanyStatus status, {
    String? reason,
  }) => _guard(() async {
    final json = await _api.patchJson(
      '$_basePath/$id/status',
      body: {
        'status': status.apiValue,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        // Le serveur prévient le recruteur responsable par e-mail.
        'notifyRecruiter':
            status == CompanyStatus.rejected ||
            status == CompanyStatus.suspended,
      },
    );
    return _company(_object(json));
  });

  @override
  Future<void> deleteCompany(String id) =>
      _guard(() => _api.deleteJson('$_basePath/$id'));

  /// Corps commun à la création et à la modification.
  ///
  /// Le logo choisi localement n'est pas envoyé ici : il faudra un endpoint
  /// d'upload (multipart) ; seule une URL de logo existante est transmise.
  Map<String, Object?> _draftBody(CompanyDraft draft) => {
    'name': draft.name,
    'siret': draft.siret,
    'sector': draft.sector,
    'city': draft.city,
    'address': draft.address,
    'website': draft.website,
    if (draft.logo?.url case final url? when url.isNotEmpty) 'logoUrl': url,
  };

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException catch (error) {
      throw AdminCompanyException(switch (error.statusCode) {
        401 => 'Ta session a expiré. Reconnecte-toi.',
        403 => 'Accès refusé : cette page est réservée aux administrateurs.',
        404 => 'Cette entreprise n’existe plus.',
        409 => 'Une entreprise est déjà enregistrée avec ce SIRET.',
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
    throw const AdminCompanyException('Réponse inattendue du serveur.');
  }

  AdminCompany _company(Map<String, Object?> json) {
    final recruiter = json['recruiter'];
    final recruiterJson = recruiter == null ? null : _object(recruiter);
    final logoUrl = json['logoUrl'] as String?;
    return AdminCompany(
      id: '${json['id']}',
      name: json['name'] as String? ?? '',
      siret: json['siret'] as String? ?? '',
      sector: json['sector'] as String? ?? '',
      city: json['city'] as String? ?? '',
      address: json['address'] as String? ?? '',
      website: json['website'] as String? ?? '',
      logo: logoUrl == null || logoUrl.isEmpty
          ? null
          : CompanyLogo(url: logoUrl),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      status: CompanyStatus.fromApi(json['status'] as String?),
      recruiterName: recruiterJson?['name'] as String?,
      recruiterEmail: recruiterJson?['email'] as String?,
      statusReason: json['statusReason'] as String?,
    );
  }
}
