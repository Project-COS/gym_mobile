import 'dart:convert';

import 'auth_session.dart';
import 'session_storage.dart';

typedef CurrentTimeProvider = DateTime Function();

// Serializes AuthSession into storage and owns expiry cleanup. The time provider
// is injectable so expiry behavior stays deterministic in tests.
class AuthSessionRepository {
  AuthSessionRepository({
    required SessionStorage storage,
    CurrentTimeProvider? currentTimeProvider,
  }) : _storage = storage,
       _currentTimeProvider = currentTimeProvider ?? DateTime.now;

  final SessionStorage _storage;
  final CurrentTimeProvider _currentTimeProvider;

  Future<void> saveSession({
    required String accessToken,
    required DateTime expiresAt,
  }) {
    final session = AuthSession(accessToken: accessToken, expiresAt: expiresAt);

    // Store the whole session as one JSON value to keep read/write/delete
    // operations atomic from the repository's point of view.
    return _storage.write(jsonEncode(session.toJson()));
  }

  Future<AuthSession?> restoreSession() async {
    final storedValue = await _storage.read();

    if (storedValue == null || storedValue.trim().isEmpty) {
      return null;
    }

    try {
      final session = AuthSession.fromJson(jsonDecode(storedValue));

      if (session.isExpiredAt(_currentTimeProvider())) {
        // Expired tokens are removed immediately so ApiClient cannot reuse them.
        await clearSession();
        return null;
      }

      return session;
    } on FormatException {
      // Corrupt or legacy session data should be self-healing rather than
      // forcing every caller to handle parse failures.
      await clearSession();
      return null;
    }
  }

  Future<String?> readAccessToken() async {
    // ApiClient uses this as a safe fallback when the in-memory cubit has not
    // finished bootstrapping yet.
    return (await restoreSession())?.accessToken;
  }

  Future<void> clearSession() {
    return _storage.delete();
  }
}
