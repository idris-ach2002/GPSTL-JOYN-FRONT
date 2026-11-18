import 'dart:typed_data';
import 'dart:convert';

import '../../recruiter_studio/data/studio_store.dart';
import '../../../core/network/api_client.dart';
import '../../messaging/data/api_messaging_repository.dart';
import '../../messaging/domain/conversation.dart';

/// Contrat v1 : les routes et la normalisation sont isolées de l'interface.
abstract interface class RecruiterWorkspaceRepository {
  bool get isMock;
  Future<List<Map<String, dynamic>>> applications(int jobId);
  Future<void> updateApplication(int jobId, String id, String stage);
  Future<Map<String, dynamic>> profile();
  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> value);
  Future<Map<String, dynamic>> settings();
  Future<Map<String, dynamic>> saveSettings(Map<String, dynamic> value);
  Future<List<Map<String, dynamic>>> notifications();
  Future<void> readNotification(String id);
  Future<void> updateNotification(String id, Map<String, dynamic> changes);
  Future<void> deleteNotification(String id);
  Future<List<Map<String, dynamic>>> conversations();
  Future<Map<String, dynamic>> startConversation(
    String candidateId,
    String name,
  );
  Future<List<Map<String, dynamic>>> messages(String conversationId);
  Future<void> readConversation(String id);
  Future<Map<String, dynamic>> send(
    String conversationId,
    String text,
    String clientId,
  );
}

Map<String, dynamic> apiObject(Object? value) {
  if (value is! Map) throw const FormatException('Objet JSON attendu.');
  final root = Map<String, dynamic>.from(value);
  return root['data'] is Map
      ? Map<String, dynamic>.from(root['data'] as Map)
      : root;
}

List<Map<String, dynamic>> apiList(Object? value) {
  final body = value is Map ? (value['data'] ?? value) : value;
  final items = body is Map ? (body['items'] ?? body['content']) : body;
  if (items is! List) throw const FormatException('Liste JSON attendue.');
  return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

class ApiRecruiterWorkspaceRepository implements RecruiterWorkspaceRepository {
  ApiRecruiterWorkspaceRepository(this.api);
  final ApiClient api;
  @override
  Future<List<Map<String, dynamic>>> applications(int jobId) async {
    final items = <Map<String, dynamic>>[];
    for (var page = 1; ; page++) {
      final result = apiObject(
        await api.getJson(
          '$root/jobs/$jobId/recommendations',
          query: {'page': '$page', 'limit': '50'},
        ),
      );
      for (final row in result['content'] as List) {
        final candidate = row['candidate'] as Map;
        items.add({
          'id': row['application_id'],
          'candidateId': candidate['id'],
          'name': [
            candidate['first_name'],
            candidate['last_name'],
          ].whereType<String>().join(' '),
          'stage': row['application_status'],
          'score': row['match_score'],
          'education': candidate['headline'],
          'location': candidate['location'],
          'bio': candidate['bio'],
          'skills': candidate['skills'],
          'experience': candidate['years_of_experience'],
          'appliedAt': row['applied_at'],
        });
      }
      if (result['hasNext'] != true) return items;
    }
  }

  @override
  Future<void> updateApplication(int jobId, String id, String stage) async {
    await api.patchJson(
      '/api/v1/applications/${Uri.encodeComponent(id)}/status',
      body: {'status': stage.toUpperCase()},
    );
  }

  static const root = '/api/v1/recruiters';
  @override
  bool get isMock => false;
  @override
  Future<Map<String, dynamic>> profile() async {
    final result = apiObject(await api.getJson('$root/profile'));
    try {
      final dashboard = apiObject(await api.getJson('$root/dashboard'));
      final companyId = dashboard['companyId'];
      if (companyId != null) {
        final company = apiObject(
          await api.getJson(
            '/api/v1/companies/$companyId',
            query: {'include_jobs': 'false'},
          ),
        );
        result.addAll({'companyId': companyId, 'company': company});
      }
    } catch (_) {
      result['companyError'] = 'Les informations de l’entreprise sont indisponibles. Actualisez pour réessayer.';
    }
    return result;
  }

  Future<void> uploadPhoto(Uint8List bytes, String name) async {
    await api.sendMultipart(
      'PUT',
      '/api/v1/users/profile-picture',
      fileField: 'file',
      fileBytes: bytes,
      fileName: name,
    );
  }

  Future<void> deletePhoto() async {
    await api.deleteJson('/api/v1/users/profile-picture');
  }

  Future<void> uploadLogo(int id, Uint8List bytes, String name) async {
    await api.sendMultipart(
      'PUT',
      '/api/v1/companies/$id/logo',
      fileField: 'file',
      fileBytes: bytes,
      fileName: name,
    );
  }

  Future<void> deleteLogo(int id) async {
    await api.deleteJson('/api/v1/companies/$id/logo');
  }

  Future<void> saveCompany(int id, Map<String, dynamic> value) async {
    await api.patchJson('/api/v1/companies/$id', body: value);
  }

  Future<void> deleteCompany(int id) async {
    await api.deleteJson('/api/v1/companies/$id');
  }

  @override
  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> value) async {
    final response = await api.patchJson(
      '$root/profile',
      body: {
        for (final key in ['firstName', 'lastName'])
          if (value.containsKey(key)) key: value[key],
      },
    );
    return {
      ...value,
      ...apiObject(response ?? await api.getJson('$root/profile')),
    };
  }

  // The server stores only the recruiter's first and last names.
  // Settings are presentation preferences for this running session only.
  final Map<String, dynamic> _localSettings = {
    'emailNotifications': false,
    'messageNotifications': false,
    'matchNotifications': false,
    'profileVisible': true,
  };
  @override
  Future<Map<String, dynamic>> settings() async => Map.of(_localSettings);
  @override
  Future<Map<String, dynamic>> saveSettings(Map<String, dynamic> value) async {
    _localSettings.addAll(value);
    return Map.of(_localSettings);
  }

  @override
  Future<List<Map<String, dynamic>>> notifications() async {
    final result = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (var page = 1; ; page++) {
      final body = apiObject(
        await api.getJson(
          '/api/v1/notifications',
          query: {'page': '$page', 'limit': '50'},
        ),
      );
      final rows = body['notifications'];
      if (rows is! List) {
        throw const FormatException('Notifications attendues.');
      }
      for (final row in rows.cast<Map>()) {
        final id = '${row['id']}';
        if (!seen.add(id)) continue;
        final type = '${row['type']}';
        result.add({
          'id': id,
          'title': row['title'],
          'body': row['message'],
          'createdAt': row['createdAt'],
          'read': row['isRead'] == true,
          'kind': switch (type) {
            'NEW_MESSAGE' => 'message',
            'NEW_APPLICATION' || 'APPLICATION_UPDATE' => 'application',
            'NEW_MATCH' || 'RECOMMENDATION' => 'match',
            'INTERVIEW' => 'interview',
            'NEW_OFFER' => 'offer',
            _ => 'system',
          },
          'target': notificationTarget('${row['link'] ?? ''}', type),
        });
      }
      if (rows.isEmpty || page >= (body['totalPages'] as num? ?? 1)) break;
    }
    // Older seeded applications predate server notifications. Show their real
    // dashboard history separately, without inventing an unread notification.
    if (result.isEmpty) {
      try {
        final dashboard = apiObject(
          await api.getJson('$root/dashboard', query: {'period': '30d'}),
        );
        for (final row
            in (dashboard['activities'] as List? ?? const [])
                .whereType<Map>()) {
          final identity = jsonEncode([
            row['kind'],
            row['occurredAt'],
            row['title'],
            row['subtitle'],
          ]);
          result.add({
            'id': 'activity:$identity',
            'title': row['title'],
            'body': row['subtitle'],
            'createdAt': row['occurredAt'],
            'kind': row['kind'],
            'read': true,
            'source': 'Historique du dashboard · 30 derniers jours',
            'target': row['kind'] == 'offer'
                ? '/recruiter/jobs'
                : '/recruiter/candidates',
          });
        }
      } catch (_) {
        // Notifications loaded successfully; optional history is unavailable.
      }
    }
    return result;
  }

  // Only translate the backend's known relative links, never arbitrary URLs.
  static String notificationTarget(String link, String type) {
    final conversation = RegExp(r'^/conversations/(\d+)$').firstMatch(link);
    if (conversation != null) {
      return '/recruiter/messages?conversationId=${conversation[1]}';
    }
    final job = RegExp(r'^/recruiters/jobs/(\d+)/recommendations$')
        .firstMatch(link);
    if (job != null) return '/recruiter/jobs/${job[1]}';
    return type == 'NEW_MESSAGE'
        ? '/recruiter/messages'
        : '/recruiter/candidates';
  }

  void clearActivityState() {
    _localSettings.updateAll((key, value) => key == 'profileVisible');
  }

  @override
  Future<void> readNotification(String id) async {
    if (id.startsWith('activity:')) return;
    await api.patchJson(
      '/api/v1/notifications/${Uri.encodeComponent(id)}/read',
    );
  }

  @override
  Future<void> updateNotification(
    String id,
    Map<String, dynamic> changes,
  ) async {
    if (changes['read'] == true) {
      await readNotification(id);
    } else if (changes['read'] == false) {
      throw UnsupportedError(
        'Le serveur ne permet pas de marquer comme non lue.',
      );
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    await api.deleteJson('/api/v1/notifications/${Uri.encodeComponent(id)}');
  }

  Future<Map<String, dynamic>> openApplication(String id) async =>
      _conversationMap(await _messaging.openForApplication(id));

  Future<Map<String, dynamic>> conversation(String id) async =>
      _conversationMap(
        ApiMessagingRepository.mapConversation(
          apiObject(
            await api.getJson(
              '/api/v1/conversations/${Uri.encodeComponent(id)}',
            ),
          ),
        ),
      );

  Future<MessagePage> messagePage(String id, {String? before}) =>
      _messaging.fetchMessages(id, before: before, limit: 100);

  // Messagerie : routes `/api/v1/conversations` du back (tag « Messaging »),
  // partagées avec l'espace candidat via [ApiMessagingRepository]. Les écrans
  // recruteur attendent des maps : on convertit ici.
  late final ApiMessagingRepository _messaging = ApiMessagingRepository(api);

  @override
  Future<List<Map<String, dynamic>>> conversations() async {
    final list = await _messaging.fetchConversations();
    return list.items.map(_conversationMap).toList();
  }

  @override
  Future<Map<String, dynamic>> startConversation(
    String candidateId,
    String name,
  ) async {
    // Le back accepte `{candidateId, jobId}` côté recruteur et prend alors la
    // dernière candidature de ce candidat sur les offres de l'entreprise.
    final json = await api.postJson(
      ApiMessagingRepository.basePath,
      body: {'candidateId': int.tryParse(candidateId) ?? candidateId},
    );
    final map = _conversationMap(
      ApiMessagingRepository.mapConversation(apiObject(json)),
    );
    if ('${map['name']}'.isEmpty) map['name'] = name;
    return map;
  }

  @override
  Future<List<Map<String, dynamic>>> messages(String conversationId) async {
    final page = await _messaging.fetchMessages(conversationId, limit: 100);
    return page.messages.map(messageMap).toList();
  }

  @override
  Future<void> readConversation(String id) => _messaging.markRead(id);

  @override
  Future<Map<String, dynamic>> send(
    String conversationId,
    String text,
    String clientId,
  ) async => messageMap(
    await _messaging.send(conversationId, text, clientId: clientId),
  );

  static Map<String, dynamic> _conversationMap(Conversation c) => {
    'id': c.id,
    'candidateId': c.candidateId,
    'applicationId': c.applicationId,
    'name': c.candidateName,
    'jobTitle': c.offerTitle,
    'offerTitle': c.offerTitle,
    'unread': c.unread,
    'lastMessage': c.lastMessage,
    'lastMessageAt': c.lastMessageAt?.toUtc().toIso8601String(),
  };

  static Map<String, dynamic> messageMap(ChatMessage m) => {
    'id': m.id,
    'clientId': m.clientId,
    'text': m.text,
    'fromMe': m.fromMe,
    'senderName': m.senderName,
    'createdAt': m.createdAt.toUtc().toIso8601String(),
    'readAt': m.readAt?.toUtc().toIso8601String(),
  };
}

/// Données de démonstration isolées par instance et conservées pendant la session.
/// Aucun faux message candidat n'est généré après un envoi.
class MockRecruiterWorkspaceRepository implements RecruiterWorkspaceRepository {
  @override
  bool get isMock => true;
  @override
  Future<List<Map<String, dynamic>>> applications(int jobId) async => [];
  @override
  Future<void> updateApplication(int jobId, String id, String stage) async {
    throw UnsupportedError('Utiliser les aperçus de démonstration.');
  }

  Map<String, dynamic> _profile = {
    'firstName': 'Camille',
    'lastName': 'Martin',
    'jobTitle': 'Responsable recrutement',
    'phone': '',
    'companyName': 'Joyn',
    'city': 'Paris',
    'website': 'https://joyn.example',
    'description':
        'Nous rapprochons les talents et les équipes qui leur correspondent.',
  };
  Map<String, dynamic> _settings = {
    'emailNotifications': true,
    'messageNotifications': true,
    'matchNotifications': true,
    'profileVisible': true,
  };
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'n1',
      'title': 'Un message vous attend',
      'body': 'Alex Dupont vous a répondu au sujet de votre offre.',
      'kind': 'message',
      'read': false,
      'target': '/recruiter/messages',
      'createdAt': '2026-10-29T15:10:00Z',
    },
    {
      'id': 'n2',
      'title': 'De nouveaux profils à découvrir',
      'body': 'Consultez les recommandations pour vos offres.',
      'kind': 'match',
      'read': false,
      'target': '/recruiter/candidates',
      'createdAt': '2026-10-29T09:00:00Z',
    },
    {
      'id': 'n3',
      'title': 'Votre offre est publiée',
      'body': 'Retrouvez vos offres et suivez les candidatures.',
      'kind': 'offer',
      'read': true,
      'target': '/recruiter/jobs',
      'createdAt': '2026-10-28T12:00:00Z',
    },
  ];
  final List<Map<String, dynamic>> _conversations = [
    {
      'id': 'c1',
      'candidateId': 'cand-001',
      'name': 'Alex Dupont',
      'jobTitle': 'Développeur Full-Stack',
      'offerTitle': 'Développeur·se Full-Stack en alternance',
      'unread': 1,
      'lastMessage': 'Bonjour, je suis disponible pour un échange jeudi.',
    },
    {
      'id': 'c2',
      'candidateId': 'cand-004',
      'name': 'Inès Leroy',
      'jobTitle': 'Développeuse Full-Stack',
      'offerTitle': 'Développeur·se Full-Stack en alternance',
      'unread': 0,
      'lastMessage': 'Merci pour votre retour !',
    },
  ];
  final Map<String, List<Map<String, dynamic>>> _messages = {
    'c1': [
      {
        'id': 'm1',
        'text': 'Bonjour Alex, votre profil nous intéresse. Seriez-vous disponible pour un premier échange ?',
        'fromMe': true,
        'createdAt': '2026-10-29T14:00:00Z',
      },
      {
        'id': 'm2',
        'text': 'Bonjour, je suis disponible pour un échange jeudi.',
        'fromMe': false,
        'createdAt': '2026-10-29T15:10:00Z',
      },
    ],
    'c2': [
      {
        'id': 'm3',
        'text': 'Merci pour votre retour !',
        'fromMe': false,
        'createdAt': '2026-10-28T10:00:00Z',
      },
    ],
  };
  Map<String, dynamic> snapshot() => jsonDecode(
    jsonEncode({
      'profile': _profile,
      'settings': _settings,
      'notifications': _notifications,
      'conversations': _conversations,
      'messages': _messages,
    }),
  ) as Map<String, dynamic>;
  void hydrate(Map<String, dynamic> state) {
    _profile = Map<String, dynamic>.from(state['profile'] as Map);
    _settings = Map<String, dynamic>.from(state['settings'] as Map);
    _notifications
      ..clear()
      ..addAll(
        (state['notifications'] as List).map(
          (e) => Map<String, dynamic>.from(e as Map),
        ),
      );
    _conversations
      ..clear()
      ..addAll(
        (state['conversations'] as List).map(
          (e) => Map<String, dynamic>.from(e as Map),
        ),
      );
    _messages
      ..clear()
      ..addAll(
        (state['messages'] as Map).map(
          (k, v) => MapEntry(
            '$k',
            (v as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList(),
          ),
        ),
      );
  }

  Map<String, dynamic> _copy(Map<String, dynamic> value) =>
      Map<String, dynamic>.from(value);
  @override
  Future<Map<String, dynamic>> profile() async => _copy(_profile);
  @override
  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> value) async {
    _profile = {..._profile, ...value};
    return profile();
  }

  @override
  Future<Map<String, dynamic>> settings() async => _copy(_settings);
  @override
  Future<Map<String, dynamic>> saveSettings(Map<String, dynamic> value) async {
    _settings = {..._settings, ...value};
    return settings();
  }

  @override
  Future<List<Map<String, dynamic>>> notifications() async =>
      _notifications.map(_copy).toList();
  @override
  Future<void> readNotification(String id) async {
    _notifications.firstWhere((n) => n['id'] == id)['read'] = true;
  }

  @override
  Future<void> updateNotification(
    String id,
    Map<String, dynamic> changes,
  ) async {
    _notifications.firstWhere((n) => n['id'] == id).addAll(changes);
  }

  @override
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n['id'] == id);
  }

  @override
  Future<List<Map<String, dynamic>>> conversations() async =>
      _conversations.map(_copy).toList();
  @override
  Future<Map<String, dynamic>> startConversation(
    String candidateId,
    String name,
  ) async {
    for (final item in _conversations) {
      if (item['candidateId'] == candidateId) return _copy(item);
    }
    final item = <String, dynamic>{
      'id': 'c${DateTime.now().microsecondsSinceEpoch}',
      'candidateId': candidateId,
      'name': name,
      'unread': 0,
      'lastMessage': '',
    };
    _conversations.insert(0, item);
    _messages[item['id'] as String] = [];
    return _copy(item);
  }

  @override
  Future<List<Map<String, dynamic>>> messages(String conversationId) async =>
      (_messages[conversationId] ?? []).map(_copy).toList();
  @override
  Future<void> readConversation(String id) async {
    _conversations.firstWhere((c) => c['id'] == id)['unread'] = 0;
  }

  @override
  Future<Map<String, dynamic>> send(
    String conversationId,
    String text,
    String clientId,
  ) async {
    final items = _messages.putIfAbsent(conversationId, () => []);
    for (final item in items) {
      if (item['clientId'] == clientId) return _copy(item);
    }
    final message = <String, dynamic>{
      'id': clientId,
      'clientId': clientId,
      'text': text,
      'fromMe': true,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    items.add(message);
    _conversations.firstWhere((c) => c['id'] == conversationId)['lastMessage'] =
        text;
    return _copy(message);
  }
}

/// Le scénario mock est persistant et isolé par compte. Aucune session auth n'est stockée ici.
class PersistentMockWorkspaceRepository
    extends MockRecruiterWorkspaceRepository {
  PersistentMockWorkspaceRepository(this.store, this.userId);
  final StudioStore store;
  final String userId;
  Future<void> _pending = Future.value();
  String get key => 'joyn.mock.workspace.v2.$userId';
  Future<void> restore() async {
    final raw = await store.read(key);
    if (raw != null) hydrate(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  Future<T> _transaction<T>(Future<T> Function() action) {
    final operation = _pending.then((_) async {
      final before = snapshot();
      try {
        final result = await action();
        await store.write(key, jsonEncode(snapshot()));
        return result;
      } catch (_) {
        hydrate(before);
        rethrow;
      }
    });
    _pending = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return operation;
  }

  @override
  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> value) =>
      _transaction(() => super.saveProfile(value));
  @override
  Future<Map<String, dynamic>> saveSettings(Map<String, dynamic> value) =>
      _transaction(() => super.saveSettings(value));
  @override
  Future<void> readNotification(String id) =>
      _transaction(() => super.readNotification(id));
  @override
  Future<void> updateNotification(String id, Map<String, dynamic> changes) =>
      _transaction(() => super.updateNotification(id, changes));
  @override
  Future<void> deleteNotification(String id) =>
      _transaction(() => super.deleteNotification(id));
  @override
  Future<Map<String, dynamic>> startConversation(
    String candidateId,
    String name,
  ) => _transaction(() => super.startConversation(candidateId, name));
  @override
  Future<void> readConversation(String id) =>
      _transaction(() => super.readConversation(id));
  @override
  Future<Map<String, dynamic>> send(
    String conversationId,
    String text,
    String clientId,
  ) => _transaction(() => super.send(conversationId, text, clientId));
}
