import 'package:flutter/foundation.dart' show kIsWeb;

enum AppDataMode { auto, mock, api }

class AppEnvironment {
  const AppEnvironment({
    required this.dataMode,
    required this.apiBaseUrl,
    required this.apiTimeout,
  });

  factory AppEnvironment.fromCompileTime() {
    const rawMode = String.fromEnvironment(
      'JOYN_DATA_MODE',
      defaultValue: 'auto',
    );
    const apiBaseUrl = String.fromEnvironment('JOYN_API_BASE_URL');
    const rawTimeout = String.fromEnvironment(
      'JOYN_API_TIMEOUT_MS',
      defaultValue: '12000',
    );

    final mode = switch (rawMode.trim().toLowerCase()) {
      'mock' => AppDataMode.mock,
      'api' => AppDataMode.api,
      _ => AppDataMode.auto,
    };
    final timeoutMs = int.tryParse(rawTimeout) ?? 12000;
    return AppEnvironment(
      dataMode: mode,
      apiBaseUrl: resolveApiBaseUrl(
        apiBaseUrl,
        mode: mode,
        isWeb: kIsWeb,
        page: Uri.base,
      ),
      apiTimeout: Duration(milliseconds: timeoutMs.clamp(1000, 60000).toInt()),
    );
  }

  /// Hôtes servis par le Worker Cloudflare (`deploy/api-worker.mjs`), qui
  /// relaie `/api/v1/*` vers le back.
  static const String cloudflareWorkerSuffix = '.workers.dev';

  /// Calcule l'URL du back.
  ///
  /// - `same-origin` : le site lui-même (relais du Worker).
  /// - Rien de fourni, mode `auto`, page servie par le Worker Cloudflare :
  ///   on utilise aussi le relais. Ainsi le site en ligne parle au vrai back
  ///   même si la commande de build Cloudflare oublie les `--dart-define`.
  ///   En local (`localhost`), rien ne change : mode démo par défaut.
  static String resolveApiBaseUrl(
    String raw, {
    required AppDataMode mode,
    required bool isWeb,
    required Uri page,
  }) {
    final value = raw.trim();
    if (isWeb && value == 'same-origin') return page.origin;
    if (value.isEmpty &&
        isWeb &&
        mode == AppDataMode.auto &&
        page.host.endsWith(cloudflareWorkerSuffix)) {
      return page.origin;
    }
    return value;
  }

  final AppDataMode dataMode;
  final String apiBaseUrl;
  final Duration apiTimeout;

  bool get useApi => switch (dataMode) {
    AppDataMode.api => true,
    AppDataMode.mock => false,
    AppDataMode.auto => apiBaseUrl.isNotEmpty,
  };

  bool _isHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        ['http', 'https'].contains(uri.scheme) &&
        uri.host.isNotEmpty &&
        !uri.hasQuery &&
        !uri.hasFragment;
  }

  void validate() {
    if (useApi && apiBaseUrl.isEmpty) {
      throw StateError(
        'JOYN_DATA_MODE=api exige JOYN_API_BASE_URL. '
        'Utilisez JOYN_DATA_MODE=mock pour le mode simulé.',
      );
    }
    if (apiBaseUrl.isNotEmpty && !_isHttpUrl(apiBaseUrl)) {
      throw StateError('JOYN_API_BASE_URL doit être une URL absolue.');
    }
  }
}
