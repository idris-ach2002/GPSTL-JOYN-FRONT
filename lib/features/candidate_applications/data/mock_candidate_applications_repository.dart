import '../domain/candidate_application.dart';
import 'candidate_applications_repository.dart';

/// Implémentation SIMULÉE, en attendant le backend.
///
/// - Par défaut, aucune candidature (utile aux tests) ;
/// - [MockCandidateApplicationsRepository.demo] : jeu de démonstration.
///
/// La page « Matchs » y ajoute les offres glissées à droite
/// ([addInterested]), qui arrivent dans la colonne « Intéressé ».
class MockCandidateApplicationsRepository
    implements CandidateApplicationsRepository {
  MockCandidateApplicationsRepository({
    this.latency = const Duration(milliseconds: 500),
    List<CandidateApplication> applications = const [],
    DateTime Function()? clock,
  }) : _applications = [...applications],
       _clock = clock ?? DateTime.now;

  /// Candidatures de démonstration, datées par rapport à aujourd'hui.
  factory MockCandidateApplicationsRepository.demo({
    Duration latency = const Duration(milliseconds: 500),
    DateTime Function()? clock,
  }) {
    final now = (clock ?? DateTime.now)();
    return MockCandidateApplicationsRepository(
      latency: latency,
      clock: clock,
      applications: demoApplications(now),
    );
  }

  /// Délai simulé de chaque appel (mettre `Duration.zero` dans les tests).
  final Duration latency;
  final List<CandidateApplication> _applications;
  final DateTime Function() _clock;

  /// Copie des candidatures enregistrées (pour les tests).
  List<CandidateApplication> get applications =>
      List.unmodifiable(_applications);

  /// Ajoute une offre à la colonne « Intéressé » (geste depuis « Matchs »).
  ///
  /// Sans effet si une candidature existe déjà pour cette offre.
  void addInterested({
    required String offerId,
    required String companyName,
    required String jobTitle,
    required int matchScore,
  }) {
    if (_applications.any((a) => a.offerId == offerId)) return;
    _applications.add(
      CandidateApplication(
        id: 'app-$offerId',
        offerId: offerId,
        status: ApplicationStatus.interested,
        companyName: companyName,
        jobTitle: jobTitle,
        matchScore: matchScore,
        appliedAt: _clock(),
      ),
    );
  }

  /// Retire la candidature liée à [offerId] (geste annulé depuis « Matchs »).
  void removeForOffer(String offerId) =>
      _applications.removeWhere((a) => a.offerId == offerId);

  @override
  Future<ApplicationsPage> fetchApplications({
    int page = 1,
    int pageSize = CandidateApplicationsRepository.defaultPageSize,
  }) async {
    await Future<void>.delayed(latency);
    final sorted = [..._applications]
      ..sort((a, b) {
        final aDate = a.appliedAt ?? DateTime(0);
        final bDate = b.appliedAt ?? DateTime(0);
        return bDate.compareTo(aDate);
      });
    final start = (page - 1) * pageSize;
    final items = start >= sorted.length
        ? <CandidateApplication>[]
        : sorted.sublist(start, (start + pageSize).clamp(0, sorted.length));
    final totalPages = sorted.isEmpty ? 1 : (sorted.length / pageSize).ceil();
    return ApplicationsPage(
      items: items,
      page: page,
      totalPages: totalPages,
      totalItems: sorted.length,
    );
  }

  @override
  Future<String> createConversation(String applicationId) async {
    await Future<void>.delayed(latency);
    return 'mock-conversation-$applicationId';
  }

  @override
  Future<CandidateApplication> sendApplication(String applicationId) async {
    await Future<void>.delayed(latency);
    final index = _applications.indexWhere((a) => a.id == applicationId);
    if (index < 0) throw StateError('Candidature inconnue : $applicationId');
    final current = _applications[index];
    if (current.status != ApplicationStatus.interested) {
      throw StateError('Candidature déjà envoyée : $applicationId');
    }
    final sent = current.copyWith(
      status: ApplicationStatus.sent,
      appliedAt: _clock(),
    );
    _applications[index] = sent;
    return sent;
  }

  /// Jeu de démonstration : entreprises distinctes de celles de la pile
  /// « Matchs », pour qu'une offre ne soit jamais à la fois proposée et
  /// déjà candidatée.
  static List<CandidateApplication> demoApplications(DateTime now) {
    DateTime ago(int days) => now.subtract(Duration(days: days));
    DateTime inDays(int days, int hour) {
      final day = DateTime(now.year, now.month, now.day + days);
      return day.add(Duration(hours: hour));
    }

    return [
      CandidateApplication(
        id: 'app-seed-1',
        offerId: 'seed-1',
        status: ApplicationStatus.interested,
        companyName: 'Orbit Paiements',
        jobTitle: 'Développeur·euse Front-End Vue',
        matchScore: 86,
        appliedAt: ago(1),
      ),
      CandidateApplication(
        id: 'app-seed-2',
        offerId: 'seed-2',
        status: ApplicationStatus.sent,
        companyName: 'Atelier Numérique',
        jobTitle: 'Développeur·euse Full-Stack',
        matchScore: 84,
        appliedAt: ago(2),
      ),
      CandidateApplication(
        id: 'app-seed-3',
        offerId: 'seed-3',
        status: ApplicationStatus.sent,
        companyName: 'Medisoft',
        jobTitle: 'Développeur·euse Back-End Node.js',
        matchScore: 79,
        appliedAt: ago(5),
      ),
      CandidateApplication(
        id: 'app-seed-4',
        offerId: 'seed-4',
        status: ApplicationStatus.interview,
        companyName: 'Banque Horizon',
        jobTitle: 'Développeur·euse Java en alternance',
        matchScore: 88,
        appliedAt: ago(9),
        interviewAt: inDays(2, 13),
      ),
      CandidateApplication(
        id: 'app-seed-5',
        offerId: 'seed-5',
        status: ApplicationStatus.interview,
        companyName: 'Kanopé',
        jobTitle: 'Développeur·euse React',
        matchScore: 82,
        appliedAt: ago(12),
        interviewAt: inDays(4, 10),
      ),
      CandidateApplication(
        id: 'app-seed-6',
        offerId: 'seed-6',
        status: ApplicationStatus.rejected,
        companyName: 'Datalis',
        jobTitle: 'Data Engineer junior',
        matchScore: 68,
        appliedAt: ago(7),
      ),
    ];
  }
}
