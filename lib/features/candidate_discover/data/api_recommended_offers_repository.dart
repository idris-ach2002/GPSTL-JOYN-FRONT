import '../../../core/network/api_client.dart';
import '../../candidate_applications/data/pending_interests_store.dart';
import '../domain/recommended_offer.dart';
import 'recommended_offers_repository.dart';

/// Implémentation backend de [RecommendedOffersRepository].
///
/// Contrat attendu : voir `docs/candidate-discover.md`. Le mapping est
/// tolérant (champs absents, enveloppe `data`, alias de noms) pour ne pas
/// casser l'écran si le backend évolue légèrement.
class ApiRecommendedOffersRepository implements RecommendedOffersRepository {
  ApiRecommendedOffersRepository(this._api, {PendingInterestsStore? interests})
      : interests = interests ?? PendingInterestsStore();

  final PendingInterestsStore interests;
  final Map<String, RecommendedOffer> _knownOffers = {};

  final ApiClient _api;

  static const String basePath = '/api/v1/candidates/recommendations';

  @override
  Future<DiscoverFeed> fetchFeed({
    DiscoverFilters filters = const DiscoverFilters(),
  }) async {
    final json = await _api.getJson(basePath, query: {
      'page': '1', 'limit': '50',
      if (filters.rhythm != null) 'rhythm_type': filters.rhythm,
      if (filters.location != null) 'location': filters.location,
    });
    final root = _unwrap(_asMap(json));
    final offerRows = _asList(root['content']);
    final mapped = <RecommendedOffer>[];
    final companies = <String, Map<String, dynamic>>{};
    for (final row in offerRows) {
      final envelope = _asMap(row);
      final job = _asMap(envelope['offer']);
      if (job.isEmpty) continue;
      final companyId = _string(job['company_id']);
      if (companyId.isNotEmpty && !companies.containsKey(companyId)) {
        try {
          companies[companyId] = _asMap(await _api.getJson('/api/v1/companies/$companyId'));
        } catch (_) {
          companies[companyId] = const {};
        }
      }
      final merged = {...job, 'match_score': envelope['match_score'],
        'score_breakdown': envelope['score_breakdown'],
        'company': companies[companyId] ?? const <String,dynamic>{}};
      final offer = mapOffer(merged);
      _knownOffers[offer.id] = offer;
      if (!interests.isHidden(offer.id)) mapped.add(offer);
    }
    return DiscoverFeed(
      offers: mapped, filters: filters,
      totalCompatible: _nullableInt(root['totalElements']) ?? mapped.length,
    );
  }

  @override
  Future<void> submitDecision(String offerId, SwipeDecision decision) async {
    final offer = _knownOffers[offerId];
    if (offer == null) throw StateError('Offre introuvable dans le flux.');
    if (decision == SwipeDecision.interested) {
      interests.interested(offerId, title: offer.title,
        companyName: offer.company.name);
    } else {
      // Save and pass are visual session-local actions (no backend endpoint).
      interests.hide(offerId);
    }
  }

  @override
  Future<void> cancelDecision(String offerId) async {
    interests.undo(offerId);
  }

  /// Convertit le corps de `GET /recommendations` en [DiscoverFeed].
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
    );
  }

  /// Convertit une offre JSON en [RecommendedOffer].
  static RecommendedOffer mapOffer(Map<String, dynamic> json) {
    final company = _asMap(json['company']);
    final criteria = json['score_breakdown'] ?? json['criteria'] ?? json['matching'] ?? json['match'];
    return RecommendedOffer(
      id: _string(json['id']),
      title: _string(json['title']),
      company: OfferCompany(
        name: _string(company['name'] ?? json['companyName']),
        sector: _string(company['sector']),
        headcount: _nullableInt(company['headcount'] ?? company['size']),
        city: _string(company['city'] ?? json['location']),
        logoUrl: _nullableString(company['logoUrl']),
      ),
      compatibility: _int(
        json['match_score'] ?? json['compatibility'] ?? json['compatibilityScore'] ?? json['score'],
      ).clamp(0, 100),
      location: _string(json['location']),
      commuteMinutes: _nullableInt(json['commuteMinutes']),
      rhythm: _string(json['rhythm_type'] ?? json['rhythm']),
      remoteDays: _nullableInt(json['remoteDays']),
      monthlySalary: _nullableInt((json['salary_period'] == 'MONTH' ? json['salary_min'] : null)),
      contractType: _string(json['contract_type'] ?? json['contractType'] ?? json['contract']),
      description: _string(json['description']),
      skills: _asList(json['skills']).map((skill) {
        if (skill is String) return OfferSkill(name: skill, matched: false);
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

  /// Accepte une liste `[{label, score}]` ou un objet `{technos: 90, …}`.
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
        MatchCriterion(
          label: _criterionLabels[entry.key] ?? entry.key,
          score: _int(entry.value).clamp(0, 100),
        ),
    ];
  }

  static const Map<String, String> _criterionLabels = {
    'skills': 'Technos',
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
