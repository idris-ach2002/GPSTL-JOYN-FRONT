import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:joyn_front/core/network/api_client.dart';

void main() {
  test('ApiClient prépare GET et bearer token', () async {
    late http.Request captured;
    final client = ApiClient(
      baseUrl: 'https://api.joyn.test',
      tokenProvider: () async => 'token-test',
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response('{"ok":true}', 200);
      }),
    );

    final result = await client.getJson(
      '/api/v1/recruiters/dashboard',
      query: {'period': '30d'},
    );

    expect(captured.method, 'GET');
    expect(captured.url.queryParameters['period'], '30d');
    expect(captured.headers['Authorization'], 'Bearer token-test');
    expect(result, {'ok': true});
  });

  test('ApiClient supporte POST PATCH PUT DELETE en JSON', () async {
    final methods = <String>[];
    final bodies = <Object?>[];
    final client = ApiClient(
      baseUrl: 'https://api.joyn.test',
      httpClient: MockClient((request) async {
        methods.add(request.method);
        bodies.add(request.body.isEmpty ? null : jsonDecode(request.body));
        return http.Response('{}', 200);
      }),
    );

    await client.postJson('/resource', body: {'a': 1});
    await client.patchJson('/resource/1', body: {'b': 2});
    await client.putJson('/resource/1', body: {'c': 3});
    await client.deleteJson('/resource/1');

    expect(methods, ['POST', 'PATCH', 'PUT', 'DELETE']);
    expect(bodies.take(3), [
      {'a': 1},
      {'b': 2},
      {'c': 3},
    ]);
  });
}
