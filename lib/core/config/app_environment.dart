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
      apiBaseUrl: apiBaseUrl.trim(),
      apiTimeout: Duration(milliseconds: timeoutMs.clamp(1000, 60000).toInt()),
    );
  }

  final AppDataMode dataMode;
  final String apiBaseUrl;
  final Duration apiTimeout;

  bool get useApi => switch (dataMode) {
    AppDataMode.api => true,
    AppDataMode.mock => false,
    AppDataMode.auto => apiBaseUrl.isNotEmpty,
  };

  void validate() {
    if (useApi && apiBaseUrl.isEmpty) {
      throw StateError(
        'JOYN_DATA_MODE=api exige JOYN_API_BASE_URL. '
        'Utilisez JOYN_DATA_MODE=mock pour le mode simulé.',
      );
    }
    if (apiBaseUrl.isNotEmpty && Uri.tryParse(apiBaseUrl)?.hasScheme != true) {
      throw StateError('JOYN_API_BASE_URL doit être une URL absolue.');
    }
  }
}
