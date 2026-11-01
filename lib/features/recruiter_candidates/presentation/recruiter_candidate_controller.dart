import 'package:flutter/foundation.dart';

import '../data/recruiter_candidate_repository.dart';
import '../domain/recruiter_candidate_models.dart';

class RecruiterCandidateController extends ChangeNotifier {
  RecruiterCandidateController(this._repository);

  final RecruiterCandidateRepository _repository;

  CandidateRecommendationQuery _query = const CandidateRecommendationQuery();
  CandidateRecommendationData? _data;
  int _currentIndex = 0;
  bool _loading = false;
  bool _actionLoading = false;
  Object? _error;
  RecruiterCandidateRecommendation? _reciprocalMatch;

  CandidateRecommendationQuery get query => _query;
  CandidateRecommendationData? get data => _data;
  bool get isLoading => _loading;
  bool get isActionLoading => _actionLoading;
  Object? get error => _error;
  RecruiterCandidateRecommendation? get reciprocalMatch => _reciprocalMatch;
  int get currentIndex => _currentIndex;

  RecruiterCandidateRecommendation? get currentCandidate {
    final items = _data?.items ?? const <RecruiterCandidateRecommendation>[];
    if (items.isEmpty) return null;
    final safeIndex = _currentIndex.clamp(0, items.length - 1).toInt();
    return items[safeIndex];
  }

  int get currentPosition {
    if (_data?.items.isEmpty ?? true) return 0;
    return ((_data!.page - 1) * _query.limit) + _currentIndex + 1;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _repository.fetchRecommendations(_query);
      _currentIndex = 0;
      if (_query.offerId == null && _data?.selectedOfferId != null) {
        _query = _query.copyWith(offerId: _data!.selectedOfferId);
      }
    } catch (error) {
      _error = error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> selectOffer(int? offerId) async {
    _query = _query.copyWith(
      offerId: offerId,
      clearOffer: offerId == null,
      page: 1,
    );
    await load();
  }

  Future<void> selectStatus(CandidateRecommendationStatus status) async {
    if (_query.status == status) return;
    _query = _query.copyWith(status: status, page: 1);
    await load();
  }

  Future<void> setScoreMinimum(double value) async {
    _query = _query.copyWith(scoreMin: value, page: 1);
    await load();
  }

  Future<void> applyFilters({
    required double scoreMin,
    String? location,
    double? experienceMin,
    double? experienceMax,
    List<String> skills = const [],
    String? contractType,
  }) async {
    _query = CandidateRecommendationQuery(
      offerId: _query.offerId,
      status: _query.status,
      scoreMin: scoreMin.clamp(0, 100).toDouble(),
      page: 1,
      limit: _query.limit,
      sort: _query.sort,
      location: location?.trim().isEmpty == true ? null : location?.trim(),
      experienceMin: experienceMin,
      experienceMax: experienceMax,
      skills: skills,
      contractType: contractType?.trim().isEmpty == true
          ? null
          : contractType?.trim(),
    );
    await load();
  }

  Future<void> clearFilters() async {
    _query = CandidateRecommendationQuery(
      offerId: _query.offerId,
      status: _query.status,
      page: 1,
      limit: _query.limit,
      sort: _query.sort,
    );
    await load();
  }

  void selectIndex(int index) {
    final items = _data?.items ?? const <RecruiterCandidateRecommendation>[];
    if (items.isEmpty) return;
    final safeIndex = index.clamp(0, items.length - 1).toInt();
    if (safeIndex == _currentIndex) return;
    _currentIndex = safeIndex;
    notifyListeners();
  }

  Future<void> next() async {
    final data = _data;
    final length = data?.items.length ?? 0;
    if (data == null || length == 0) return;
    if (_currentIndex < length - 1) {
      _currentIndex++;
      notifyListeners();
      return;
    }
    if (data.page < data.totalPages) {
      _query = _query.copyWith(page: data.page + 1);
      await load();
    }
  }

  Future<void> previous() async {
    final data = _data;
    if (data == null || data.items.isEmpty) return;
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
      return;
    }
    if (data.page > 1) {
      _query = _query.copyWith(page: data.page - 1);
      await load();
      final length = _data?.items.length ?? 0;
      if (length > 0) {
        _currentIndex = length - 1;
        notifyListeners();
      }
    }
  }

  Future<void> goToPage(int page) async {
    final data = _data;
    if (data == null) return;
    final target = page.clamp(1, data.totalPages).toInt();
    if (target == data.page) return;
    _query = _query.copyWith(page: target);
    await load();
  }

  Future<void> saveCurrent() =>
      _updateCurrent(CandidateRecommendationStatus.saved);
  Future<void> rejectCurrent() =>
      _updateCurrent(CandidateRecommendationStatus.rejected);
  Future<void> interestCurrent() =>
      _updateCurrent(CandidateRecommendationStatus.interested);

  Future<void> updateCandidate(
    RecruiterCandidateRecommendation candidate,
    CandidateRecommendationStatus status,
  ) => _update(candidate, status);

  Future<void> _updateCurrent(CandidateRecommendationStatus status) async {
    final candidate = currentCandidate;
    if (candidate == null) return;
    await _update(candidate, status);
  }

  Future<void> _update(
    RecruiterCandidateRecommendation candidate,
    CandidateRecommendationStatus status,
  ) async {
    if (_actionLoading) return;
    _actionLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.updateStatus(candidate.id, status);
      if (result.reciprocalMatch &&
          status == CandidateRecommendationStatus.interested) {
        _reciprocalMatch = result;
      }
      _data = await _repository.fetchRecommendations(_query);
      final length = _data?.items.length ?? 0;
      if (length == 0) {
        _currentIndex = 0;
      } else if (_currentIndex >= length) {
        _currentIndex = length - 1;
      }
    } catch (error) {
      _error = error;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

  void clearReciprocalMatch() {
    _reciprocalMatch = null;
    notifyListeners();
  }

  Future<RecruiterCandidateRecommendation> fetchCandidate(String id) =>
      _repository.fetchCandidate(id);

  Future<void> reload() => load();
}
