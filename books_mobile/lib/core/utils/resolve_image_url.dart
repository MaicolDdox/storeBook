import '../config/app_config.dart';

String? resolveImageUrl(String? rawValue) {
  if (rawValue == null) {
    return null;
  }

  final value = rawValue.trim();
  if (value.isEmpty) {
    return null;
  }

  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }

  if (value.startsWith('/storage/')) {
    return _joinUrl(AppConfig.apiOrigin, value);
  }

  if (value.startsWith('storage/')) {
    return _joinUrl(AppConfig.apiOrigin, '/$value');
  }

  if (value.startsWith('/public/')) {
    return _joinUrl(
      AppConfig.apiOrigin,
      '/storage/${value.substring('/public/'.length)}',
    );
  }

  if (value.startsWith('public/')) {
    return _joinUrl(
      AppConfig.apiOrigin,
      '/storage/${value.substring('public/'.length)}',
    );
  }

  if (value.startsWith('/')) {
    return _joinUrl(AppConfig.apiOrigin, value);
  }

  return _joinUrl(AppConfig.apiOrigin, '/storage/$value');
}

String _joinUrl(String origin, String path) {
  final normalizedOrigin = origin.endsWith('/')
      ? origin.substring(0, origin.length - 1)
      : origin;
  final normalizedPath = path.startsWith('/') ? path : '/$path';
  return '$normalizedOrigin$normalizedPath';
}
