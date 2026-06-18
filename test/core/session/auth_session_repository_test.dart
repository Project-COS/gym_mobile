import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/session/auth_session_repository.dart';

import '../../helpers/in_memory_session_storage.dart';

void main() {
  final currentTime = DateTime.utc(2026, 6, 12, 12);

  group('AuthSessionRepository', () {
    test('saves and restores an active session', () async {
      final storage = InMemorySessionStorage();
      final repository = AuthSessionRepository(
        storage: storage,
        currentTimeProvider: () => currentTime,
      );

      await repository.saveSession(
        accessToken: 'member-token',
        expiresAt: currentTime.add(const Duration(days: 1)),
      );
      final session = await repository.restoreSession();

      expect(session?.accessToken, 'member-token');
      expect(session?.expiresAt, currentTime.add(const Duration(days: 1)));
    });

    test('deletes an expired session during bootstrap', () async {
      final storage = InMemorySessionStorage(
        value: jsonEncode({
          'accessToken': 'expired-token',
          'expiresAt': currentTime
              .subtract(const Duration(seconds: 1))
              .toIso8601String(),
        }),
      );
      final repository = AuthSessionRepository(
        storage: storage,
        currentTimeProvider: () => currentTime,
      );

      final session = await repository.restoreSession();

      expect(session, isNull);
      expect(storage.value, isNull);
      expect(storage.deleteCount, 1);
    });

    test('deletes malformed session data', () async {
      final storage = InMemorySessionStorage(value: '{invalid-json');
      final repository = AuthSessionRepository(
        storage: storage,
        currentTimeProvider: () => currentTime,
      );

      final session = await repository.restoreSession();

      expect(session, isNull);
      expect(storage.deleteCount, 1);
    });

    test('provides the active token for API authorization', () async {
      final storage = InMemorySessionStorage();
      final repository = AuthSessionRepository(
        storage: storage,
        currentTimeProvider: () => currentTime,
      );
      await repository.saveSession(
        accessToken: 'bearer-token',
        expiresAt: currentTime.add(const Duration(hours: 1)),
      );

      expect(await repository.readAccessToken(), 'bearer-token');
    });
  });
}
