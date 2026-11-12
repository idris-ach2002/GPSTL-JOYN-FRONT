import 'package:flutter/foundation.dart';

import '../data/candidate_applications_repository.dart';
import '../domain/candidate_application.dart';

/// Résultat d'une demande d'ouverture de conversation.
sealed class ConversationOutcome {
  const ConversationOutcome();
}

/// Conversation disponible : naviguer vers `/messages/:conversationId`.
final class ConversationReady extends ConversationOutcome {
  const ConversationReady(this.conversationId);
  final String conversationId;
}

/// Le statut de la candidature ne permet pas (encore) d'échanger.
final class ConversationUnavailable extends ConversationOutcome {
  const ConversationUnavailable();
}

/// La création du fil a échoué (réseau, serveur…).
final class ConversationFailed extends ConversationOutcome {
  const ConversationFailed(this.message);
  final String message;
}

/// État de l'écran « Mes candidatures ».
///
/// Créé à l'ouverture de la page (voir `app_router.dart`).
class CandidateApplicationsController extends ChangeNotifier {
  CandidateApplicationsController(
    this._repository, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final CandidateApplicationsRepository _repository;
  final DateTime Function() _clock;

  List<CandidateApplication> _items = const [];
  int _page = 0;
  int _totalPages = 1;
  int _totalItems = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String? _openingId;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;

  /// Erreur de chargement à afficher (en français), ou `null`.
  String? get errorMessage => _errorMessage;

  /// Candidature dont la conversation est en cours d'ouverture.
  String? get openingId => _openingId;

  bool get hasMore => _page < _totalPages;

  /// Nombre total de candidatures (toutes pages confondues).
  int get totalItems => _totalItems;

  /// Date du jour, pour les libellés « Aujourd'hui », « Il y a 2 j »…
  DateTime get now => _clock();

  /// Candidatures chargées, les plus récentes d'abord.
  List<CandidateApplication> get items => _items;

  List<CandidateApplication> byStatus(ApplicationStatus status) =>
      _items.where((item) => item.status == status).toList();

  /// Entretiens prévus entre lundi et dimanche de la semaine en cours.
  int get interviewsThisWeek {
    final today = _clock();
    final monday = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));
    final nextMonday = monday.add(const Duration(days: 7));
    return _items.where((item) {
      final date = item.interviewAt;
      return item.status == ApplicationStatus.interview &&
          date != null &&
          !date.isBefore(monday) &&
          date.isBefore(nextMonday);
    }).length;
  }

  /// Charge (ou recharge) la première page.
  ///
  /// TODO(backend): pour un statut « en temps réel », rappeler cette méthode
  /// sur notification (WebSocket / push) quand le back le proposera.
  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _repository.fetchApplications(page: 1);
      _items = _sorted(result.items);
      _apply(result);
    } catch (e) {
      debugPrint('Erreur pendant le chargement des candidatures : $e');
      _errorMessage =
          'Impossible de charger tes candidatures. Réessaie plus tard.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajoute la page suivante à la liste.
  Future<void> loadMore() async {
    if (!hasMore || _isLoadingMore || _isLoading) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final result = await _repository.fetchApplications(page: _page + 1);
      _items = _sorted([..._items, ...result.items]);
      _apply(result);
    } catch (e) {
      debugPrint('Erreur pendant le chargement de la page suivante : $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Renvoie la conversation liée à [application], en la créant si son
  /// statut le permet.
  Future<ConversationOutcome> openConversation(
    CandidateApplication application,
  ) async {
    if (application.hasConversation) {
      return ConversationReady(application.conversationId!);
    }
    if (!application.canStartConversation) {
      return const ConversationUnavailable();
    }

    _openingId = application.id;
    notifyListeners();
    try {
      final id = await _repository.createConversation(application.id);
      _items = [
        for (final item in _items)
          item.id == application.id ? item.copyWith(conversationId: id) : item,
      ];
      return ConversationReady(id);
    } catch (e) {
      debugPrint('Erreur pendant la création de la conversation : $e');
      return const ConversationFailed(
        'Impossible d’ouvrir la conversation. Réessaie plus tard.',
      );
    } finally {
      _openingId = null;
      notifyListeners();
    }
  }

  /// Candidatures en cours d'envoi.
  final Set<String> _sendingIds = {};

  bool isSending(String applicationId) => _sendingIds.contains(applicationId);

  /// Envoie une candidature « Intéressé » à l'entreprise.
  ///
  /// Mise à jour optimiste : la carte passe dans « Candidatures envoyées »
  /// tout de suite, et revient si l'envoi échoue. Renvoie `true` si l'envoi
  /// a réussi.
  Future<bool> send(CandidateApplication application) async {
    if (application.status != ApplicationStatus.interested ||
        _sendingIds.contains(application.id)) {
      return false;
    }
    _sendingIds.add(application.id);
    _replace(
      application.copyWith(status: ApplicationStatus.sent, appliedAt: now),
    );
    try {
      await _repository.sendApplication(application.id);
      return true;
    } catch (e) {
      debugPrint('Erreur pendant l’envoi de la candidature : $e');
      _replace(application);
      return false;
    } finally {
      _sendingIds.remove(application.id);
      notifyListeners();
    }
  }

  void _replace(CandidateApplication updated) {
    _items = _sorted([
      for (final item in _items) item.id == updated.id ? updated : item,
    ]);
    notifyListeners();
  }

  void _apply(ApplicationsPage result) {
    _page = result.page;
    _totalPages = result.totalPages;
    _totalItems = result.totalItems;
  }

  /// Ordre antéchronologique ; les candidatures sans date vont à la fin.
  static List<CandidateApplication> _sorted(List<CandidateApplication> list) {
    return [...list]..sort((a, b) {
      final aDate = a.appliedAt;
      final bDate = b.appliedAt;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
  }
}
