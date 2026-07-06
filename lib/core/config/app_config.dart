import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  // Read from --dart-define at compile time, for example:
  // flutter run --dart-define=API_BASE_URL=https://api.example.com/api/mobile/
  static const String _configuredApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get apiBaseUrl {
    // An explicit API_BASE_URL always wins so staging, production, and local
    // devices can point to the correct backend without changing source code.
    if (_configuredApiBaseUrl.trim().isNotEmpty) {
      return _configuredApiBaseUrl.trim();
    }

    // Release builds must not silently use a developer machine fallback.
    if (kReleaseMode) {
      throw StateError('API_BASE_URL must be provided for release builds.');
    }

    // Android emulators reach the host machine through 10.0.2.2, not localhost.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api/mobile/';
    }

    // Desktop, web, and other debug targets can use the host localhost backend.
    return 'http://localhost:3000/api/mobile/';
  }

  static Uri get apiBaseUri {
    final uri = Uri.tryParse(apiBaseUrl);

    // ApiClient expects a valid HTTP(S) base URI before composing endpoints.
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      throw StateError(
        'API_BASE_URL must be a valid HTTP(S) URL. Current value: $apiBaseUrl',
      );
    }

    // Production traffic should not use clear-text HTTP.
    if (kReleaseMode && uri.scheme != 'https') {
      throw StateError('API_BASE_URL must use HTTPS in release builds.');
    }

    return uri;
  }
}
