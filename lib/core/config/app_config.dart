import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static const String _configuredApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get apiBaseUrl {
    if (_configuredApiBaseUrl.trim().isNotEmpty) {
      return _configuredApiBaseUrl.trim();
    }

    if (kReleaseMode) {
      throw StateError('API_BASE_URL must be provided for release builds.');
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api/mobile/';
    }

    return 'http://localhost:3000/api/mobile/';
  }

  static Uri get apiBaseUri {
    final uri = Uri.tryParse(apiBaseUrl);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      throw StateError(
        'API_BASE_URL must be a valid HTTP(S) URL. Current value: $apiBaseUrl',
      );
    }

    if (kReleaseMode && uri.scheme != 'https') {
      throw StateError('API_BASE_URL must use HTTPS in release builds.');
    }

    return uri;
  }
}
