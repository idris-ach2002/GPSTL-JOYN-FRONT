import '../../../core/network/api_client.dart';
import '../../candidate_applications/data/pending_interests_store.dart';
import '../domain/recommended_offer.dart';
import 'recommended_offers_repository.dart';

class ApiRecommendedOffersRepository
    implements
        RecommendedOffersRepository,
        PaginatedRecommendedOffersRepository {
  ApiRecommendedOffersRepository(this._api, {PendingInterestsStore? interests})
    : interests = interests ?? PendingInterestsStore();

  final ApiClient _api;
  final PendingInterestsStore interests;

  static const String basePath = '/api/v1/candidates/recommendations';

  final Map<String, RecommendedOffer> _knownOffers = {};

  // Cache des informations des entreprises.
  final Map<String, Map<String, dynamic>> _companyCache = {};

  // Compétences du candidat.
  Set<String> _profileSkills = {};

  bool _metadataLoaded = false;

  @override
  Future<DiscoverFeed> fetchFeed({
    DiscoverFilters filters = const DiscoverFilters(),
  }) {
    return fetchPage(filters: filters, page: 1, limit: 50);
  }

  @override
  Future<DiscoverFeed> fetchPage({
    DiscoverFilters filters = const DiscoverFilters(),
    int page = 1,
    int limit = 10,
  }) async {
    final loadMetadata = page == 1 && !_metadataLoaded;

    // Les appels indépendants sont exécutés en parallèle.
    final responses = await Future.wait<Object?>([
      _api.getJson(
        basePath,
        query: {
          'page': '$page',
          'limit': '$limit',
          'contract_type': filters.contractType,
          'remote': filters.remote,
          if (filters.rhythm != null) 'rhythm_type': filters.rhythm,
          if (filters.location != null) 'location': filters.location,
        },
      ),

      if (loadMetadata)
        _api
            .getJson('/api/v1/candidates/workspace')
            .catchError((Object _) => null),

      if (loadMetadata)
        _api
            .getJson('/api/v1/candidates/profile')
            .catchError((Object _) => null),
    ]);

    final root = _unwrap(_asMap(responses.first));
    final offerRows = _asList(root['content']);

    // Les favoris et le profil ne sont chargés
    // qu'une fois pendant la session.
    if (loadMetadata) {
      final workspace = _asMap(responses[1]);

      if (workspace.isNotEmpty) {
        interests.restore(_asList(workspace['bookmarks']));
      }

      final profile = _asMap(responses[2]);

      _profileSkills = _asList(profile['skills'])
          .map(
            (skill) => skill is Map ? _string(skill['name']) : _string(skill),
          )
          .map((skill) => skill.trim().toLowerCase())
          .where((skill) => skill.isNotEmpty)
          .toSet();

      _metadataLoaded = true;
    }

    // Compatibilité avec les anciennes réponses :
    // les entreprises manquantes sont chargées
    // en parallèle et mises en cache.
    final missingCompanyIds = <String>{};

    for (final row in offerRows) {
      final envelope = _asMap(row);

      if (_asMap(envelope['company']).isNotEmpty) {
        continue;
      }

      final job = _asMap(envelope['offer']);
      final id = _string(job['company_id']);

      if (id.isNotEmpty && !_companyCache.containsKey(id)) {
        missingCompanyIds.add(id);
      }
    }

    await Future.wait(missingCompanyIds.map(_loadCompany));

    final mapped = <RecommendedOffer>[];

    for (final row in offerRows) {
      final envelope = _asMap(row);
      final job = _asMap(envelope['offer']);

      if (job.isEmpty) continue;

      final companyId = _string(job['company_id']);
      final inlineCompany = _asMap(envelope['company']);

      final merged = <String, dynamic>{
        ...job,
        'skills': [
          for (final skill in _asList(job['skills']))
            {
              'name': '$skill',
              'matched': _profileSkills.contains('$skill'.trim().toLowerCase()),
            },
        ],
        'match_score': envelope['match_score'],
        'score_breakdown': envelope['score_breakdown'],
        'company': inlineCompany.isNotEmpty
            ? inlineCompany
            : (_companyCache[companyId] ?? const <String, dynamic>{}),
      };

      final offer = mapOffer(merged);

      _knownOffers[offer.id] = offer;

      if (!interests.isHidden(offer.id)) {
        mapped.add(offer);
      }
    }

    return DiscoverFeed(
      offers: mapped,
      filters: filters,
      totalCompatible: _nullableInt(root['totalElements']) ?? mapped.length,
      hasNext: root['hasNext'] == true,
    );
  }

  Future<void> _loadCompany(String companyId) async {
    try {
      _companyCache[companyId] = _asMap(
        await _api.getJson('/api/v1/companies/$companyId'),
      );
    } catch (_) {
      // Une erreur sur l'entreprise ne bloque pas
      // toute la liste des offres.
      _companyCache[companyId] = const {};
    }
  }

  @override
  Future<void> submitDecision(String offerId, SwipeDecision decision) async {
    final offer = _knownOffers[offerId];

    if (offer == null) {
      throw StateError('Offre introuvable dans le flux.');
    }

    await _api.putJson(
      '/api/v1/candidates/workspace/offers/$offerId',
      body: {
        'state': switch (decision) {
          SwipeDecision.interested => 'INTERESTED',
          SwipeDecision.save => 'SAVED',
          SwipeDecision.skip => 'HIDDEN',
        },
        'collection_name': decision == SwipeDecision.save
            ? 'Plus tard'
            : 'À postuler',
      },
    );

    if (decision == SwipeDecision.interested) {
      interests.interested(
        offerId,
        title: offer.title,
        companyName: offer.company.name,
      );
    } else {
      interests.hide(offerId);
    }
  }

  @override
  Future<void> cancelDecision(String offerId) async {
    await _api.deleteJson('/api/v1/candidates/workspace/offers/$offerId');

    interests.undo(offerId);
  }

  static DiscoverFeed mapFeed(Map<String, dynamic> body) {
    final offers = _asList(body['items'] ?? body['offers'] ?? body['content'])
        .map((item) => mapOffer(_asMap(item)))
        .toList();

    final filters = _asMap(body['filters']);

    return DiscoverFeed(
      offers: offers,
      filters: DiscoverFilters(
        rhythm: _nullableString(filters['rhythm']),
        location: _nullableString(filters['location']),
      ),
      totalCompatible: _nullableInt(
        body['totalCompatible'] ?? body['totalItems'],
      ),
      hasNext: body['hasNext'] == true,
    );
  }

  static RecommendedOffer mapOffer(Map<String, dynamic> json) {
    final company = _asMap(json['company']);

    final criteria =
        json['score_breakdown'] ??
        json['criteria'] ??
        json['matching'] ??
        json['match'];

    return RecommendedOffer(
      id: _string(json['id']),
      title: _string(json['title']),
      company: OfferCompany(
        name: _string(company['name'] ?? json['companyName']),
        sector: _string(company['sector']),
        headcount: _nullableInt(company['headcount'] ?? company['size']),
        city: _string(company['city'] ?? json['location']),
        logoUrl: _nullableString(company['logoUrl'] ?? company['logo_url']),
      ),
      compatibility: _int(
        json['match_score'] ??
            json['compatibility'] ??
            json['compatibilityScore'] ??
            json['score'],
      ).clamp(0, 100),
      location: _string(json['location']),
      commuteMinutes: _nullableInt(json['commuteMinutes']),
      distanceKm: double.tryParse('${_asMap(criteria)['distance_km'] ?? ''}'),
      remotePolicy: _nullableString(json['remote_policy']),
      rhythm: _string(json['rhythm_type'] ?? json['rhythm']),
      remoteDays: _nullableInt(json['remoteDays']),
      monthlySalary: _nullableInt(
        json['salary_period'] == 'MONTH' ? json['salary_min'] : null,
      ),
      contractType: _string(
        json['contract_type'] ?? json['contractType'] ?? json['contract'],
      ),
      description: _string(json['description']),
      skills: _asList(json['skills']).map((skill) {
        if (skill is String) {
          return OfferSkill(name: skill, matched: false);
        }

        final map = _asMap(skill);

        return OfferSkill(
          name: _string(map['name']),
          matched: map['matched'] == true,
        );
      }).toList(),
      criteria: _mapCriteria(criteria),
      alumniCount: _int(json['alumniCount']),
    );
  }

  static List<MatchCriterion> _mapCriteria(Object? value) {
    if (value is List) {
      return value
          .map(_asMap)
          .map(
            (map) => MatchCriterion(
              label: _string(map['label']),
              score: _int(map['score']).clamp(0, 100),
            ),
          )
          .toList();
    }

    final map = _asMap(value);

    return [
      for (final entry in map.entries)
        if (_criterionLabels.containsKey(entry.key) && entry.value != null)
          MatchCriterion(
            label: _criterionLabels[entry.key] ?? entry.key,
            score: _int(entry.value).clamp(0, 100),
          ),
    ];
  }

  static const Map<String, String> _criterionLabels = {
    'skills': 'Compétences',
    'education': 'Formation & niveau',
    'experience': 'Expérience',
    'availability': 'Disponibilité',
    'rhythm': 'Rythme',
    'commute': 'Trajet',
    'location': 'Trajet',
  };

  static Map<String, dynamic> _unwrap(Map<String, dynamic> root) {
    final data = root['data'];

    return data is Map<String, dynamic> ? data : root;
  }

  static Map<String, dynamic> _asMap(Object? value) =>
      value is Map<String, dynamic> ? value : const {};

  static List<Object?> _asList(Object? value) =>
      value is List ? value : const [];

  static String _string(Object? value) => value?.toString().trim() ?? '';

  static String? _nullableString(Object? value) {
    final text = _string(value);
    return text.isEmpty ? null : text;
  }

  static int _int(Object? value) => _nullableInt(value) ?? 0;

  static int? _nullableInt(Object? value) => switch (value) {
    int v => v,
    num v => v.round(),
    String v => num.tryParse(v)?.round(),
    _ => null,
  };
}
