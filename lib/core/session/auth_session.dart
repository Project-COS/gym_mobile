class AuthSession {
  AuthSession({required String accessToken, required DateTime expiresAt})
    : accessToken = _validateAccessToken(accessToken),
      expiresAt = expiresAt.toUtc();

  factory AuthSession.fromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid session data.');
    }

    final accessToken = json['accessToken'];
    final expiresAtValue = json['expiresAt'];

    if (accessToken is! String || expiresAtValue is! String) {
      throw const FormatException('Invalid session data.');
    }

    final expiresAt = DateTime.tryParse(expiresAtValue);

    if (expiresAt == null) {
      throw const FormatException('Invalid session expiry.');
    }

    try {
      return AuthSession(accessToken: accessToken, expiresAt: expiresAt);
    } on ArgumentError {
      throw const FormatException('Invalid session token.');
    }
  }

  final String accessToken;
  final DateTime expiresAt;

  bool isExpiredAt(DateTime value) {
    return !expiresAt.isAfter(value.toUtc());
  }

  Map<String, Object?> toJson() {
    return {
      'accessToken': accessToken,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  static String _validateAccessToken(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(value, 'accessToken', 'Must not be empty.');
    }

    return normalizedValue;
  }
}
