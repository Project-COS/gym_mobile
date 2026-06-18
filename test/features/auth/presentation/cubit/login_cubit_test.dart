import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/network/api_exception.dart';
import 'package:do_gym/core/session/auth_session_cubit.dart';
import 'package:do_gym/core/session/auth_session_repository.dart';
import 'package:do_gym/features/auth/presentation/cubit/login_cubit.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/in_memory_session_storage.dart';

void main() {
  group('LoginCubit', () {
    test('rejects invalid input without calling the repository', () async {
      final authRepository = FakeAuthRepository();
      final cubit = _buildCubit(authRepository: authRepository);

      final success = await cubit.submit(
        email: 'invalid-email',
        password: '',
        rememberMe: false,
      );

      expect(success, isFalse);
      expect(authRepository.loginCount, 0);
      expect(cubit.state.errorMessage, 'Masukkan alamat email yang valid.');

      await cubit.close();
    });

    test('starts an in-memory session when remember me is disabled', () async {
      final storage = InMemorySessionStorage();
      final sessionCubit = AuthSessionCubit(
        repository: AuthSessionRepository(storage: storage),
      );
      final cubit = LoginCubit(
        authRepository: FakeAuthRepository(),
        sessionCubit: sessionCubit,
      );

      final success = await cubit.submit(
        email: 'member@example.com',
        password: 'password123',
        rememberMe: false,
      );

      expect(success, isTrue);
      expect(sessionCubit.state.status, AuthSessionStatus.authenticated);
      expect(sessionCubit.state.accessToken, 'member-token');
      expect(storage.value, isNull);

      await cubit.close();
      await sessionCubit.close();
    });

    test('persists the session when remember me is enabled', () async {
      final storage = InMemorySessionStorage();
      final sessionCubit = AuthSessionCubit(
        repository: AuthSessionRepository(storage: storage),
      );
      final cubit = LoginCubit(
        authRepository: FakeAuthRepository(),
        sessionCubit: sessionCubit,
      );

      final success = await cubit.submit(
        email: 'member@example.com',
        password: 'password123',
        rememberMe: true,
      );

      expect(success, isTrue);
      expect(storage.value, isNotNull);

      await cubit.close();
      await sessionCubit.close();
    });

    test('maps unauthorized API errors for the login form', () async {
      final cubit = _buildCubit(
        authRepository: FakeAuthRepository(
          error: const ApiException(
            type: ApiExceptionType.unauthorized,
            message: 'Invalid email or password.',
            statusCode: 401,
          ),
        ),
      );

      final success = await cubit.submit(
        email: 'member@example.com',
        password: 'wrong-password',
        rememberMe: false,
      );

      expect(success, isFalse);
      expect(cubit.state.errorMessage, 'Email atau password salah.');
      expect(cubit.state.isSubmitting, isFalse);

      await cubit.close();
    });
  });
}

LoginCubit _buildCubit({required FakeAuthRepository authRepository}) {
  final sessionCubit = AuthSessionCubit(
    repository: AuthSessionRepository(storage: InMemorySessionStorage()),
  );

  return LoginCubit(authRepository: authRepository, sessionCubit: sessionCubit);
}
