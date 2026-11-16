import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/core/config/app_environment.dart';

/// Régression : le site en ligne était compilé sans `--dart-define` et
/// tournait en mode démo (seuls les faux comptes fonctionnaient).
void main() {
  final worker = Uri.parse(
    'https://gpstl-joyn-front.joynpstl.workers.dev/#/login',
  );
  final local = Uri.parse('http://localhost:8081/#/login');

  String resolve(String raw, AppDataMode mode, Uri page, {bool web = true}) =>
      AppEnvironment.resolveApiBaseUrl(raw, mode: mode, isWeb: web, page: page);

  test('sur le Worker Cloudflare, sans réglage, on passe par le relais', () {
    final url = resolve('', AppDataMode.auto, worker);
    expect(url, 'https://gpstl-joyn-front.joynpstl.workers.dev');
    expect(
      AppEnvironment(
        dataMode: AppDataMode.auto,
        apiBaseUrl: url,
        apiTimeout: const Duration(seconds: 12),
      ).useApi,
      isTrue,
    );
  });

  test('en local, sans réglage, on reste en mode démo', () {
    expect(resolve('', AppDataMode.auto, local), isEmpty);
  });

  test('un mode démo explicite est respecté, même en ligne', () {
    expect(resolve('', AppDataMode.mock, worker), isEmpty);
  });

  test('une URL fournie ou same-origin reste prioritaire', () {
    expect(
      resolve(' https://api.joyn.test ', AppDataMode.api, worker),
      'https://api.joyn.test',
    );
    expect(
      resolve('same-origin', AppDataMode.api, local),
      'http://localhost:8081',
    );
  });

  test('hors Web (mobile), aucune déduction depuis l’adresse', () {
    expect(resolve('', AppDataMode.auto, worker, web: false), isEmpty);
  });
}
