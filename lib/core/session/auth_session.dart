// Small value object for the authenticated runtime session. It stays separate
// from member profile data so token lifecycle can be handled independently.
class AuthSession {
  AuthSession({required String accessToken, required DateTime expiresAt})
    : accessToken = _validateAccessToken(accessToken),
      // Store expiry in UTC so comparisons are stable across device time zones.
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
      // Normalize constructor validation failures into FormatException so the
      // repository can treat malformed stored data the same way.
      throw const FormatException('Invalid session token.');
    }
  }

  final String accessToken;
  final DateTime expiresAt;

  bool isExpiredAt(DateTime value) {
    // A token that expires exactly at value is no longer usable.
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

    // Empty tokens should fail before they can be written to secure storage.
    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(value, 'accessToken', 'Must not be empty.');
    }

    return normalizedValue;
  }
}
