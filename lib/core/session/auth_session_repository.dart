import 'dart:convert';

import 'auth_session.dart';
import 'session_storage.dart';

typedef CurrentTimeProvider = DateTime Function();

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
        await clearSession();
        return null;
      }

      return session;
    } on FormatException {
      await clearSession();
      return null;
    }
  }

  Future<String?> readAccessToken() async {
    return (await restoreSession())?.accessToken;
  }

  Future<void> clearSession() {
    return _storage.delete();
  }
}
