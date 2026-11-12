import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/admin_company.dart';
import 'admin_company_repository.dart';

class ApiAdminCompanyRepository implements AdminCompanyRepository {
  ApiAdminCompanyRepository(this.api);
  final ApiClient api;
  final Map<String, AdminCompany> _cached = {};

  @override
  Future<CompanyPage> fetchCompanies(CompanyQuery query) async {
    try {
      // The backend accepts NOT_VERIFIED / VERIFIED / REJECTED and page+limit.
      // A combined rejected/suspended filter must be handled in the UI.
      final status = switch (query.status) {
        CompanyStatusFilter.pending => 'NOT_VERIFIED',
        CompanyStatusFilter.approved => 'VERIFIED',
        CompanyStatusFilter.rejectedOrSuspended => 'REJECTED',
        _ => null,
      };
      final body = _map(
        await api.getJson(
          '/api/v1/admin/companies',
          query: {
            'page': '${query.page}',
            'limit': '${query.pageSize}',
            if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
            if (status != null) 'status': status,
            if (query.sector != null && query.sector!.isNotEmpty)
              'sector': query.sector,
            'sort_by': query.sort.field == 'name' ? 'name' : 'created_at',
            'order': query.sort.direction,
          },
        ),
      );
      final items = [
        for (final row in body['data'] as List? ?? const [])
          _company(_map(row)),
      ];
      for (final item in items) {
        _cached[item.id] = item;
      }
      final pagination = _map(body['pagination']);
      return CompanyPage(
        items: items,
        total: _int(pagination['total_items'], fallback: items.length),
        page: _int(pagination['current_page'], fallback: query.page),
        pageSize: query.pageSize,
      );
    } on ApiException catch (error) {
      throw AdminCompanyException(
        'Entreprises indisponibles (${error.statusCode ?? 'réseau'}).',
        statusCode: error.statusCode,
      );
    }
  }

  AdminCompany _company(Map<String, dynamic> j) => AdminCompany(
    id: '${j['id']}',
    name: '${j['name'] ?? ''}',
    siret: '${j['siret'] ?? ''}',
    sector: '${j['sector'] ?? ''}',
    city: '',
    website: '${j['website'] ?? ''}',
    createdAt:
        DateTime.tryParse('${j['created_at']}') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    status: CompanyStatus.fromApi(j['verification_status']?.toString()),
    logo: j['logo_url'] == null
        ? null
        : CompanyLogo(url: j['logo_url']?.toString()),
  );

  @override
  Future<AdminCompany> updateStatus(
    String id,
    CompanyStatus status, {
    String? reason,
  }) async {
    final encoded = switch (status) {
      CompanyStatus.approved => 'VERIFIED',
      CompanyStatus.rejected => 'REJECTED',
      _ => 'NOT_VERIFIED',
    };
    await api.patchJson(
      '/api/v1/admin/companies/$id/status',
      body: {'verificationStatus': encoded},
    );
    final old = _cached[id];
    if (old == null)
      throw const AdminCompanyException('Actualisez la liste des entreprises.');
    final updated = old.copyWith(status: status);
    _cached[id] = updated;
    return updated;
  }

  @override
  Future<AdminCompany> createCompany(CompanyDraft draft) async =>
      throw const AdminCompanyException(
        'Création d’entreprise non disponible dans cette API.',
      );
  @override
  Future<AdminCompany> updateCompany(String id, CompanyDraft draft) async =>
      throw const AdminCompanyException(
        'Modification d’entreprise non disponible dans cette API.',
      );
  @override
  Future<void> deleteCompany(String id) async =>
      throw const AdminCompanyException(
        'Suppression d’entreprise non disponible dans cette API.',
      );

  Map<String, dynamic> _map(Object? v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
  int _int(Object? v, {int fallback = 0}) =>
      v is num ? v.toInt() : int.tryParse('$v') ?? fallback;
}
