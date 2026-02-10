import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _apiOriginOverride = String.fromEnvironment(
    'API_ORIGIN',
    defaultValue: '',
  );

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }

    return 'http://127.0.0.1:8000/api';
  }

  static String get apiOrigin {
    if (_apiOriginOverride.isNotEmpty) {
      return _apiOriginOverride.endsWith('/')
          ? _apiOriginOverride.substring(0, _apiOriginOverride.length - 1)
          : _apiOriginOverride;
    }

    final uri = Uri.parse(apiBaseUrl);
    final hasCustomPort = uri.hasPort;
    final portSegment = hasCustomPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$portSegment';
  }
}
