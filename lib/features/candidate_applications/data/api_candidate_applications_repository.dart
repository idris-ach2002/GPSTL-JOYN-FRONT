import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../messaging/data/api_messaging_repository.dart';
import 'pending_interests_store.dart';
import '../domain/candidate_application.dart';
import 'candidate_applications_repository.dart';

/// Implémentation branchée sur l'API JOYN.
///
/// TODO(backend): les chemins et noms de champs ci-dessous suivent la user
/// story (`GET /api/v1/candidates/applications`) ; les vérifier avec le
/// contrat réel. La lecture accepte plusieurs variantes de noms pour
/// limiter les retouches.
class ApiCandidateApplicationsRepository
    implements CandidateApplicationsRepository {
  ApiCandidateApplicationsRepository(
    this._api, {
    PendingInterestsStore? interests,
  }) : interests = interests ?? PendingInterestsStore();
  final PendingInterestsStore interests;

  final ApiClient _api;

  static const String _basePath = '/api/v1/candidates/applications';

  @override
  Future<ApplicationsPage> fetchApplications({
    int page = 1,
    int pageSize = CandidateApplicationsRepository.defaultPageSize,
  }) async {
    final json = await _api.getJson(
      _basePath,
      query: {
        'page': '$page',
        'limit': '${pageSize.clamp(1, 50)}',
        'sort': 'created_at,desc',
      },
    );
    final server = _mapPage(_asMap(json), requestedPage: page);
    if (page != 1) return server;
    final workspace = _asMap(
      await _api.getJson('/api/v1/candidates/workspace'),
    );
    interests.restore(_asList(workspace['bookmarks']));
    final submittedOfferIds = server.items.map((a) => a.offerId).toSet();
    final local = interests.items
        .where((a) => !submittedOfferIds.contains(a.offerId))
        .toList();
    return ApplicationsPage(
      items: [...local, ...server.items],
      page: server.page,
      totalPages: server.totalPages,
      totalItems: server.totalItems + local.length,
    );
  }

  @override
  Future<String> createConversation(String applicationId) async {
    // `POST /api/v1/conversations` : 201 si créée, 200 si elle existait.
    // Le back refuse (403) avant le stade entretien.
    final json = await _api.postJson(
      ApiMessagingRepository.basePath,
      body: {'application_id': int.tryParse(applicationId) ?? applicationId},
    );
    final conversation = ApiMessagingRepository.mapConversation(
      _unwrap(_asMap(json)),
    );
    if (conversation.id.isEmpty) {
      throw StateError('Réponse sans identifiant de conversation.');
    }
    return conversation.id;
  }

  @override
  Future<CandidateApplication> sendApplication(
    String applicationId, {
    String? coverMessage,
    Uint8List? coverPdf,
    String? coverPdfName,
  }) async {
    final offerId = interests.findOfferId(applicationId);
    if (offerId == null) {
      throw UnsupportedError(
        'Seuls les intérêts locaux non envoyés peuvent être soumis.',
      );
    }
    const path = '/api/v1/applications';
    final raw = coverPdf == null
        ? await _api.postJson(
            path,
            body: {
              'jobOfferId': int.parse(offerId),
              'coverMessage': ?coverMessage,
            },
          )
        : await _api.sendMultipart(
            'POST',
            path,
            fields: {'jobOfferId': offerId},
            fileBytes: coverPdf,
            fileField: 'coverPdf',
            fileName: coverPdfName,
          );
    // Submission is authoritative; remove the temporary interest from storage.
    try {
      await _api.deleteJson('/api/v1/candidates/workspace/offers/$offerId');
    } catch (_) {
      // The application has already been submitted successfully. The list
      // filters duplicates using server application IDs on the next load.
    }
    interests.submitted(offerId);
    final data = _unwrap(_asMap(raw));
    return _mapApplication(data);
  }

  ApplicationsPage _mapPage(
    Map<String, dynamic> root, {
    required int requestedPage,
  }) {
    final body = _unwrap(root);
    final itemsJson = _asList(
      body['items'] ?? body['applications'] ?? body['content'],
    );
    final pagination = _asMap(body['pagination']);
    // Spring numérote les pages à partir de 0 (`number`).
    final springPage = _nullableInt(body['number']);
    final page =
        _nullableInt(body['page'] ?? pagination['page']) ??
        (springPage == null ? requestedPage : springPage + 1);

    return ApplicationsPage(
      items: itemsJson.map((item) => _mapApplication(_asMap(item))).toList(),
      page: page,
      totalPages:
          _nullableInt(body['totalPages'] ?? pagination['totalPages']) ?? 1,
      totalItems:
          _nullableInt(
            body['totalItems'] ??
                body['totalElements'] ??
                pagination['totalItems'],
          ) ??
          itemsJson.length,
    );
  }

  CandidateApplication _mapApplication(Map<String, dynamic> json) {
    final company = _asMap(json['company']);
    final offer = _asMap(json['offer'] ?? json['job']);
    return CandidateApplication(
      id: _nullableString(json['id']) ?? '',
      status: ApplicationStatus.fromApi(_nullableString(json['status'])),
      backendStatus: _nullableString(json['status']),
      offerId: _nullableString(
        json['jobOfferId'] ?? json['offerId'] ?? json['jobId'] ?? offer['id'],
      ),
      companyName: _nullableString(json['companyName'] ?? company['name']),
      companyLogoUrl: _nullableString(
        json['companyLogoUrl'] ?? company['logoUrl'],
      ),
      jobTitle: _nullableString(
        json['jobTitle'] ?? json['offerTitle'] ?? offer['title'],
      ),
      matchScore: _nullableInt(
        json['matchScore'] ?? json['compatibilityScore'] ?? json['score'],
      ),
      appliedAt: _date(json['createdAt'] ?? json['appliedAt']),
      interviewAt: _date(json['interviewAt'] ?? json['interviewDate']),
      conversationId: _nullableString(json['conversationId']),
    );
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final data = json['data'];
    return data is Map<String, dynamic> ? data : json;
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((key, value) => MapEntry('$key', value));
    return <String, dynamic>{};
  }

  List<dynamic> _asList(Object? value) => value is List ? value : const [];

  String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  int? _nullableInt(Object? value) {
    if (value == null) return null;
    if (value is num) return value.round();
    return num.tryParse('$value')?.round();
  }

  DateTime? _date(Object? value) {
    final text = _nullableString(value);
    return text == null ? null : DateTime.tryParse(text)?.toLocal();
  }
}
