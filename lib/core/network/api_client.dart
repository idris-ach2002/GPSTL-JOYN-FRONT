import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

typedef AuthTokenProvider = Future<String?> Function();

class ApiClient {
  ApiClient({
    required String baseUrl,
    this.timeout = const Duration(seconds: 12),
    http.Client? httpClient,
    this.tokenProvider,
  }) : _baseUri = Uri.parse(_normalizeBaseUrl(baseUrl)),
       _http = httpClient ?? http.Client();

  final Uri _baseUri;
  final Duration timeout;
  final http.Client _http;
  final AuthTokenProvider? tokenProvider;

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }

  Uri _uri(String path, [Map<String, String?> query = const {}]) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final uri = _baseUri.resolve(cleanPath);
    final params = <String, String>{
      for (final entry in query.entries)
        if (entry.value != null && entry.value!.isNotEmpty)
          entry.key: entry.value!,
    };
    return params.isEmpty ? uri : uri.replace(queryParameters: params);
  }

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await tokenProvider?.call();
    return <String, String>{
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json; charset=utf-8',
      if (token != null && token.trim().isNotEmpty)
        'Authorization': 'Bearer ${token.trim()}',
    };
  }

  Future<Object?> getJson(
    String path, {
    Map<String, String?> query = const {},
  }) async {
    try {
      final response = await _http
          .get(_uri(path, query), headers: await _headers(json: false))
          .timeout(timeout);
      return _decode(response);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException(
        message: 'Échec de la requête GET $path',
        cause: error,
      );
    }
  }

  Future<Object?> postJson(String path, {Object? body}) =>
      _write('POST', path, body: body);

  Future<Object?> patchJson(String path, {Object? body}) =>
      _write('PATCH', path, body: body);

  Future<Object?> putJson(String path, {Object? body}) =>
      _write('PUT', path, body: body);

  Future<Object?> deleteJson(String path, {Object? body}) =>
      _write('DELETE', path, body: body);

  Future<Object?> _write(String method, String path, {Object? body}) async {
    try {
      final uri = _uri(path);
      final headers = await _headers();
      final encodedBody = body == null ? null : jsonEncode(body);
      final response = switch (method) {
        'POST' =>
          await _http
              .post(uri, headers: headers, body: encodedBody)
              .timeout(timeout),
        'PATCH' =>
          await _http
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(timeout),
        'PUT' =>
          await _http
              .put(uri, headers: headers, body: encodedBody)
              .timeout(timeout),
        'DELETE' =>
          await _http
              .delete(uri, headers: headers, body: encodedBody)
              .timeout(timeout),
        _ => throw ArgumentError.value(method, 'method'),
      };
      return _decode(response);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException(
        message: 'Échec de la requête $method $path',
        cause: error,
      );
    }
  }

  Object? _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Le backend a retourné ${response.statusCode}.',
        body: response.body,
      );
    }
    if (response.body.trim().isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (error) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Réponse JSON invalide.',
        body: response.body,
        cause: error,
      );
    }
  }

  void close() => _http.close();
}
