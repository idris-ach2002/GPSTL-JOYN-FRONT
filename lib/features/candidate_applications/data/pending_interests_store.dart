import '../domain/candidate_application.dart';

/// Local-only pending interests: the backend has no LIKE/SAVE endpoint.
/// It is NOT a server-backed swipe history. Applying sends POST /applications.
class PendingInterestsStore {
  final Map<String, CandidateApplication> _pending = {};
  final Set<String> _hidden = {};

  List<CandidateApplication> get items => List.unmodifiable(_pending.values);
  bool isHidden(String id) => _hidden.contains(id);
  void interested(
    String offerId, {
    required String title,
    required String companyName,
  }) {
    _hidden.add(offerId);
    _pending[offerId] = CandidateApplication(
      id: 'local-interest-$offerId',
      status: ApplicationStatus.interested,
      offerId: offerId,
      jobTitle: title,
      companyName: companyName,
      appliedAt: DateTime.now(),
    );
  }

  void hide(String offerId) => _hidden.add(offerId);
  void undo(String offerId) {
    _hidden.remove(offerId);
    _pending.remove(offerId);
  }

  void submitted(String offerId) => _pending.remove(offerId);
  String? findOfferId(String localId) => localId.startsWith('local-interest-')
      ? localId.substring('local-interest-'.length)
      : null;
}
