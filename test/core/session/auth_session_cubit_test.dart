import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/session/auth_session_cubit.dart';
import 'package:do_gym/core/session/auth_session_repository.dart';

import '../../helpers/in_memory_session_storage.dart';

void main() {
  final currentTime = DateTime.utc(2026, 6, 12, 12);

  group('AuthSessionCubit', () {
    test('bootstraps an active session as authenticated', () async {
      final storage = InMemorySessionStorage();
      final repository = AuthSessionRepository(
        storage: storage,
        currentTimeProvider: () => currentTime,
      );
      await repository.saveSession(
        accessToken: 'member-token',
        expiresAt: currentTime.add(const Duration(hours: 1)),
      );
      final cubit = AuthSessionCubit(repository: repository);

      await cubit.bootstrap();

      expect(cubit.state.status, AuthSessionStatus.authenticated);
      expect(cubit.state.accessToken, 'member-token');

      await cubit.close();
    });

    test('falls back to unauthenticated when storage cannot be read', () async {
      final repository = AuthSessionRepository(
        storage: InMemorySessionStorage(readError: StateError('unavailable')),
        currentTimeProvider: () => currentTime,
      );
      final cubit = AuthSessionCubit(repository: repository);

      await cubit.bootstrap();

      expect(cubit.state.status, AuthSessionStatus.unauthenticated);
      expect(cubit.state.session, isNull);

      await cubit.close();
    });
  });
}
