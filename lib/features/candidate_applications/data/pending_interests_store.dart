import '../domain/candidate_application.dart';

/// Session cache of the candidate's server-backed bookmarks and pending interests.
/// The API repositories refresh it at login and after each decision.
class PendingInterestsStore {
  final Map<String, CandidateApplication> _pending = {};
  final Set<String> _hidden = {};

  List<CandidateApplication> get items => List.unmodifiable(_pending.values);
  void clear() {
    _pending.clear();
    _hidden.clear();
  }

  void restore(List<dynamic> bookmarks) {
    clear();
    for (final value in bookmarks) {
      if (value is! Map) continue;
      final id = '${value['job_offer_id'] ?? ''}';
      if (id.isEmpty) continue;
      final state = '${value['state'] ?? ''}';
      _hidden.add(id);
      if (state == 'INTERESTED') {
        interested(
          id,
          title: '${value['title'] ?? 'Offre'}',
          companyName: '${value['company_name'] ?? ''}',
        );
      }
    }
  }

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
