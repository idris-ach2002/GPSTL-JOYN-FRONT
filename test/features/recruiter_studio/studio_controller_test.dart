import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/features/recruiter_studio/data/studio_store.dart';
import 'package:joyn_front/features/recruiter_studio/data/studio_repository.dart';
import 'package:joyn_front/features/recruiter_studio/data/studio_export.dart';
import 'package:joyn_front/features/recruiter_studio/presentation/studio_controller.dart';
import 'package:joyn_front/features/recruiter_workspace/data/recruiter_workspace_repository.dart';
import 'package:joyn_front/features/recruiter_offers/data/mock_recruiter_offers_repository.dart';
import 'package:joyn_front/features/recruiter_offers/presentation/controllers/offer_management_controller.dart';
import 'package:joyn_front/features/recruiter_offers/presentation/controllers/offer_editor_controller.dart';
import 'package:joyn_front/features/recruiter_offers/domain/job_offer.dart';
import 'package:joyn_front/features/recruiter_studio/presentation/studio_offers.dart';

class BrokenStore implements StudioStore {
  @override
  Future<String?> read(String key) async => null;
  @override
  Future<void> write(String key, String value) async =>
      throw Exception('offline');
}

class DeferredRepository implements StudioRepository {
  final pending = Completer<Map<String, dynamic>>();
  @override
  Future<Map<String, dynamic>> load(String id) =>
      id == 'old' ? pending.future : Future.value({'owner': id});
  @override
  Future<Map<String, dynamic>> patch(
    String id,
    Map<String, dynamic> changes,
  ) async => changes;
}

void main() {
  test('un échec de sauvegarde mock restaure la version confirmée', () async {
    final repository = PersistentMockWorkspaceRepository(BrokenStore(), 'a');
    await repository.restore();
    await expectLater(
      repository.saveProfile({'firstName': 'Non enregistré'}),
      throwsException,
    );
    expect((await repository.profile())['firstName'], 'Camille');
  });

  test('apparence persistante sans stocker de session', () async {
    final store = MemoryStudioStore();
    final a = StudioController(store: store);
    await a.restoreDevice();
    await Future.wait([
      a.setPreference('theme', 'dark'),
      a.setPreference('accent', 'mint'),
      a.setPreference('textScale', 1.2),
    ]);
    final b = StudioController(store: store);
    await b.restoreDevice();
    expect(b.themeMode, ThemeMode.dark);
    expect(b.accent, 'mint');
    expect(b.textScale, 1.2);
    expect(await store.read('token'), isNull);
  });
  test('un échec de stockage rétablit l’apparence enregistrée', () async {
    final c = StudioController(store: BrokenStore());
    expect(await c.setPreference('theme', 'dark'), false);
    expect(c.themeMode, ThemeMode.system);
    expect(c.deviceError, isNotNull);
  });
  test(
    'mutations en file : deux notes et deux épingles ne se perdent pas',
    () async {
      final c = StudioController();
      await c.bind('recruiter-a');
      await Future.wait([
        c.upsert('notes', {'id': 'n1', 'text': 'Un'}),
        c.upsert('notes', {'id': 'n2', 'text': 'Deux'}),
        c.toggle('pinnedConversations', 'c1'),
        c.toggle('pinnedConversations', 'c2'),
      ]);
      expect(c.list('notes').length, 2);
      expect(c.contains('pinnedConversations', 'c1'), true);
      expect(c.contains('pinnedConversations', 'c2'), true);
    },
  );
  test('les données de travail sont séparées par compte', () async {
    final store = MemoryStudioStore();
    final c = StudioController(store: store);
    await c.bind('a');
    await c.upsert('tasks', {'id': 't1', 'title': 'Privée'});
    await c.bind('b');
    expect(c.list('tasks'), isEmpty);
    await c.bind('a');
    expect(c.list('tasks').single['title'], 'Privée');
  });
  test('une réponse tardive d’un autre compte est ignorée', () async {
    final r = DeferredRepository();
    final c = StudioController(repository: r);
    final old = c.bind('old');
    await c.bind('new');
    r.pending.complete({'owner': 'old'});
    await old;
    expect(c.data['owner'], 'new');
    expect(c.loading, false);
  });
  test('API studio : PATCH et relecture après 204, aucun repli mock', () async {
    final requests = <http.Request>[];
    final api = ApiClient(
      baseUrl: 'https://api.joyn.test',
      httpClient: MockClient((q) async {
        requests.add(q);
        return q.method == 'PATCH'
            ? http.Response('', 204)
            : http.Response('{"data":{"tasks":[{"id":"1"}]}}', 200);
      }),
    );
    final r = ApiStudioRepository(api);
    final data = await r.patch('a', {
      'tasks': [
        {'id': '1'},
      ],
    });
    expect((data['tasks'] as List).length, 1);
    expect(requests.map((q) => q.method), ['PATCH', 'GET']);
    expect(jsonDecode(requests.first.body), {
      'tasks': [
        {'id': '1'},
      ],
    });
  });
  test('mock persistant : profil, lectures et messages survivent à une nouvelle instance', () async {
    final store = MemoryStudioStore();
    final a = PersistentMockWorkspaceRepository(store, 'a');
    await a.restore();
    await a.saveProfile({'firstName': 'Idris'});
    await a.updateNotification('n1', {'read': true});
    await a.send('c1', 'Message persisté', 'client-1');
    final b = PersistentMockWorkspaceRepository(store, 'a');
    await b.restore();
    expect((await b.profile())['firstName'], 'Idris');
    expect((await b.notifications()).first['read'], true);
    expect((await b.messages('c1')).last['text'], 'Message persisté');
    final other = PersistentMockWorkspaceRepository(store, 'b');
    await other.restore();
    expect((await other.profile())['firstName'], 'Camille');
  });
  test('dupliquer crée un brouillon sans modifier l’original', () async {
    final r = MockRecruiterOffersRepository(latency: Duration.zero);
    final c = OfferManagementController(r);
    await c.load();
    final source = c.offers.first;
    final copied = await c.duplicateOffer(source.id);
    expect(copied, isNotNull);
    expect(copied!.id, isNot(source.id));
    expect(copied.status, JobOfferStatus.draft);
    expect(copied.skills, source.skills);
    expect((await r.fetchOffer(source.id))!.status, source.status);
  });
  test('nouvelle offre vide, défauts et modèle appliqués sans affecter une édition', () async {
    final r = MockRecruiterOffersRepository(latency: Duration.zero);
    final blank = OfferEditorController(
      r,
      emptyDraft: true,
      defaults: {'location': 'Lyon', 'contract': 'CDI', 'remote': 'REMOTE'},
    );
    expect(blank.title, isEmpty);
    expect(blank.salaryMin, isNull);
    expect(blank.location, 'Lyon');
    expect(blank.remoteMode, RemoteMode.remote);
    final offer = (await r.fetchOffers()).first;
    final templated = OfferEditorController(
      r,
      emptyDraft: true,
      template: studioOfferTemplate(offer),
    );
    expect(templated.title, offer.title);
    expect(templated.skills, offer.skills);
    final editing = OfferEditorController(
      r,
      offerId: offer.id,
      defaults: {'location': 'Autre ville'},
    );
    await editing.load();
    expect(editing.location, offer.location);
  });
  test('CSV protège les formules et échappe guillemets et retours', () {
    final csv = studioCsv([
      ['=SUM(A1)', 'a"b', 'ligne\n2', null],
    ]);
    expect(csv, contains('"\'=SUM(A1)"'));
    expect(csv, contains('"a""b"'));
    expect(csv, startsWith('\uFEFF'));
  });
  test('calendrier UTC, durée, échappement et repli UTF-8', () {
    final ics = studioCalendar([
      {
        'id': '1',
        'title': 'Entretien, équipe; ${'é' * 100}',
        'name': 'Alex',
        'location': 'Paris\nSalle 1',
        'start': '2026-10-30T10:00:00Z',
        'duration': 45,
      },
      {'id': '2', 'status': 'cancelled', 'start': '2026-10-30T13:00:00Z'},
    ], stamp: DateTime.utc(2026, 10, 29));
    expect(ics, contains('DTSTART:20261030T100000Z'));
    expect(ics, contains('DTEND:20261030T104500Z'));
    expect(ics, contains('LOCATION:Paris\\nSalle 1'));
    expect(ics, contains('SUMMARY:Entretien\\, équipe\\;'));
    expect(ics.split('BEGIN:VEVENT').length, 2);
    expect(ics.split('\r\n').every((s) => utf8.encode(s).length <= 75), true);
  });
}
