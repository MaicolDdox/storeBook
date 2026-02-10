import 'package:flutter/foundation.dart';

class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.20.55:8000',
  );
  static const String apiPrefix = '$apiBaseUrl/api';

  static const List<String> debugApiBaseCandidates = [
    'http://192.168.20.55:8000',
    'http://10.0.2.2:8000',
    'http://127.0.0.1:8000',
  ];

  static final ValueNotifier<String> _debugApiBaseUrlNotifier =
      ValueNotifier<String>(_normalizeBaseUrl(apiBaseUrl));

  static String get activeApiBaseUrl {
    if (kDebugMode) {
      return _debugApiBaseUrlNotifier.value;
    }

    return _normalizeBaseUrl(apiBaseUrl);
  }

  static String get activeApiPrefix => '${AppConfig.activeApiBaseUrl}/api';

  static ValueListenable<String> get debugApiBaseUrlListenable =>
      _debugApiBaseUrlNotifier;

  static void setDebugApiBaseUrl(String baseUrl) {
    if (!kDebugMode) {
      return;
    }

    _debugApiBaseUrlNotifier.value = _normalizeBaseUrl(baseUrl);
  }

  static String _normalizeBaseUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return 'http://192.168.20.55:8000';
    }

    final withoutTrailingSlash = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;

    if (withoutTrailingSlash.endsWith('/api')) {
      return withoutTrailingSlash.substring(
        0,
        withoutTrailingSlash.length - '/api'.length,
      );
    }

    return withoutTrailingSlash;
  }
}
